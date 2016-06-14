defmodule SparkPost.Endpoint do
  @moduledoc """
  Base client for the SparkPost API, able to make requests and interpret responses.
  This module underpins the SparkPost.* modules.
  """

  @default_endpoint "https://api.sparkpost.com/api/v1/"

  @doc """
  Make a request to the SparkPost API.

  ## Parameters
    - method: HTTP request method as atom (:get, :post, ...)
    - endpoint: SparkPost API endpoint as string ("transmissions", "templates", ...)
    - options: keyword of optional elements including:
      - :params: keyword of query parameters
      - :body: request body (string)

  ## Example
    List transmissions for the "ElixirRox" campaign:
        SparkPost.Endpoint.request(:get, "transmissions", [campaign_id: "ElixirRox"])
        #=> %SparkPost.Endpoint.Response{results: [%{"campaign_id" => "",
          "content" => %{"template_id" => "inline"}, "description" => "",
          "id" => "102258558346809186", "name" => "102258558346809186",
          "state" => "Success"}, ...], status_code: 200}
  """
  def request(method, endpoint, options) do
    url = if Keyword.has_key?(options, :params) do
      Application.get_env(:sparkpost, :api_endpoint, @default_endpoint) <> endpoint
        <> "?" <> URI.encode_query(options[:params])
    else
      Application.get_env(:sparkpost, :api_endpoint, @default_endpoint) <> endpoint
    end

    reqopts = if method in [:get, :delete] do
      [ headers: base_request_headers() ]
    else
      [
        headers: ["Content-Type": "application/json"] ++ base_request_headers(),
        body: encode_request_body(options[:body])
      ]
    end

    reqopts = [timeout: Application.get_env(:sparkpost, :http_timeout, 5000)] ++ reqopts

    %{status_code: status_code, body: json} = HTTPotion.request(method, url, reqopts)

    body = decode_response_body(json)

    if Map.has_key?(body, :errors) do
      %SparkPost.Endpoint.Error{ status_code: status_code, errors: body.errors }
    else
      %SparkPost.Endpoint.Response{ status_code: status_code, results: body.results }
    end
  end

  def marshal_response(response, struct_type, subkey\\nil)

  @doc """
  Extract a meaningful structure from a generic endpoint response:
  response.results[subkey] as struct_type
  """
  def marshal_response(%SparkPost.Endpoint.Response{} = response, struct_type, subkey) do
    if subkey do
      struct(struct_type, response.results[subkey])
    else
      struct(struct_type, response.results)
    end
  end

  def marshal_response(%SparkPost.Endpoint.Error{} = response, _struct_type, _subkey) do
    response
  end

  defp base_request_headers() do
    {:ok, version} = :application.get_key(:sparkpost, :vsn)
    [
      "User-Agent": "elixir-sparkpost/" <> to_string(version),
      "Authorization": Application.get_env(:sparkpost, :api_key)
    ]
  end

  defp encode_request_body(body) do
    body |> Washup.filter |> Poison.encode!
  end

  defp decode_response_body(body) do
    # TODO: [key: :atoms] is unsafe for open-ended structures such as
    # metadata and substitution_data
    body |> Poison.decode!([keys: :atoms])
  end
end
