defmodule SparkPost.Endpoint do
  @moduledoc """
  Base client for the SparkPost API, able to make requests and interpret responses.
  This module underpins the SparkPost.* modules.
  """

  @default_endpoint "https://api.sparkpost.com/api/v1/"

  @doc """
  Make a request to the SparkPost API.

  ## Parameters
    - `method`: HTTP 1.1 request method as an atom:
      - `:delete`
      - `:get`
      - `:head`
      - `:options`
      - `:patch`
      - `:post`
      - `:put`
    - `endpoint`: SparkPost API endpoint as string ("transmissions", "templates", ...)
    - `body`: A Map that will be encoded to JSON to be sent as the body of the request (defaults to empty)
    - `headers`: A Map of headers of the form %{"Header-Name" => "Value"} to be sent with the request
    - `options`: A Keyword list of optional elements including:
      - `:params`: A Keyword list of query parameters

  ## Example
    List transmissions for the "ElixirRox" campaign:
        SparkPost.Endpoint.request(:get, "transmissions", [campaign_id: "ElixirRox"])
        #=> %SparkPost.Endpoint.Response{results: [%{"campaign_id" => "",
          "content" => %{"template_id" => "inline"}, "description" => "",
          "id" => "102258558346809186", "name" => "102258558346809186",
          "state" => "Success"}, ...], status_code: 200}
  """
  def request(method, endpoint, body \\ %{}, headers \\ %{}, options \\ [], decode_results \\ true) do
    url = Application.get_env(:sparkpost, :api_endpoint, @default_endpoint) <> endpoint

    {:ok, request_body} = encode_request_body(body)

    request_headers =
      if method in [:get, :delete] do
        headers
      else
        Map.merge(headers, %{"Content-Type": "application/json"})
      end
      |> Map.merge(base_request_headers())

    request_options =
      options
      |> Keyword.put(:timeout, Application.get_env(:sparkpost, :http_timeout, 30_000))
      |> Keyword.put(:recv_timeout, Application.get_env(:sparkpost, :http_recv_timeout, 8000))

    HTTPoison.request(method, url, request_body, request_headers, request_options)
    |> handle_response(decode_results)
  end

  def marshal_response(response, struct_type, subkey \\ nil)

  @doc """
  Extract a meaningful structure from a generic endpoint response:
  response.results[subkey] as struct_type
  """
  def marshal_response(%SparkPost.Endpoint.Response{} = response, struct_type, nil) do
    struct(struct_type, response.results)
  end

  def marshal_response(%SparkPost.Endpoint.Response{} = response, struct_type, subkey) do
    struct(struct_type, response.results[subkey])
  end

  def marshal_response(%SparkPost.Endpoint.Error{} = response, _struct_type, _subkey) do
    response
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, decode_results)
       when code >= 200 and code < 300 do
    decoded_body = decode_response_body(body)

    if decode_results && Map.has_key?(decoded_body, :results) do
      %SparkPost.Endpoint.Response{status_code: code, results: decoded_body.results}
    else
      %SparkPost.Endpoint.Response{status_code: code, results: decoded_body}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, _decode_results)
       when code >= 400 do
    decoded_body = decode_response_body(body)

    if Map.has_key?(decoded_body, :errors) do
      %SparkPost.Endpoint.Error{status_code: code, errors: decoded_body.errors}
    end
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}, _decode_results) do
    %SparkPost.Endpoint.Error{status_code: nil, errors: [reason]}
  end

  defp base_request_headers do
    {:ok, version} = :application.get_key(:sparkpost, :vsn)

    %{
      "User-Agent": "elixir-sparkpost/" <> to_string(version),
      Authorization: Application.get_env(:sparkpost, :api_key)
    }
  end

  # Do not try to remove nils from an empty map
  defp encode_request_body(body) when is_map(body) and map_size(body) == 0, do: {:ok, ""}

  defp encode_request_body(body) do
    body |> Washup.filter() |> Poison.encode()
  end

  defp decode_response_body(body) when byte_size(body) == 0, do: ""

  defp decode_response_body(body) do
    body |> Poison.decode!(keys: :atoms)
  end
end
