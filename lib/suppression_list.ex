defmodule SparkPost.SuppressionList do
  @moduledoc """
  The SparkPost Suppression List API for working with suppression lists.
  Use `SparkPost.SuppressionList.delete/1` to delete a single entry from a list,
  `SparkPost.SuppressionList.upsert_one/3` to insert or update a single list entry,
  or `SparkPost.SuppressionList.search/1` to search through your account's suppression list.

  Check out the documentation for each function
  or use the [SparkPost API reference](https://developers.sparkpost.com/api/suppression_list.html) for details.

  Returned by `SparkPost.SuppressionList.delete/1`:
    - \\{:ok, ""}

  Returned by `SparkPost.SuppressionList.upsert_one/3`:
    - {:ok, message} (A success message string)

  Returned by `SparkPost.SuppressionList.search/1`.
    - %SparkPost.SuppressionList.SearchResult{}
  """

  alias SparkPost.Endpoint

  @doc """
  Insert or update a single entry in the suppression list.
  Returns a single string with the success message if the entry
  was updated or inserted. Returns a %SparkPost.Endpoint.Error{} with a 400
  if there was an issue with the request format.

  Parameters:
    - recipient: the email to insert or update in the suppression list
    - type: one of "transactional" or "non_transactional"
    - description (optional): optional description of this entry in the suppression list
  """
  def upsert_one(recipient, type, description \\ nil) do
    body = if description == nil do
      %{type: type}
    else
      %{type: type, description: description}
    end
    response = Endpoint.request(:put, "suppression-list/#{recipient}", body)
    case response do
      %SparkPost.Endpoint.Response{status_code: 200, results: results} ->
        {:ok, Map.get(results, :message, "")}
      _ -> {:error, response}
    end
  end

  @doc """
  Deletes a specific entry from the list. Returns an empty string if
  the deletion was successful. Returns a %SparkPost.Endpoint.Error{} with a 404
  if the specified entry is not in the list. Returns a %SparkPost.Endpoint.Error{}
  with a 403 if the entry could not be removed for any reason (such as Compliance).

  Parameters:
    recipient: the entry to delete from the suppression list.
  """
  def delete(recipient) do
    response = Endpoint.request(:delete, "suppression-list/#{recipient}", %{}, %{}, [], false)
    case response do
      %SparkPost.Endpoint.Response{status_code: 204} ->
        {:ok, ""}
      _ -> {:error, response}
    end
  end

  @doc """
  Execute a search of the suppression list based on the provided
  parameters.

  ### Possible Parameters
   - to: Datetime the entries were last updated, in the format YYYY-MM-DDTHH:mm:ssZ (defaults to now)
   - from: Datetime the entries were last updated, in the format YYYY-MM-DDTHH:mm:ssZ
   - domain: Domain of entries to include in search
   - cursor: Results cursor (first query should use the value "initial")
   - per_page: Max number of results to return per page (between 1 and 10,000)
   - page: Results page number to return. Use if looking for less than 10,000 results. Otherwise
       use the cursor param.
   - sources: Sources of entries to include in the search.
   - types: Types of entries to include in the search (transactional and/or non_transactional)
   - description: Description of entries to include in the search.
  """
  def search(params \\ []) do
    response = Endpoint.request(:get, "suppression-list", %{}, %{}, [params: params], false)
    case response do
      %SparkPost.Endpoint.Response{results: body} ->
        mapped_results = Enum.map(body.results, fn res -> struct(SparkPost.SuppressionList.ListEntry, res) end)
        %SparkPost.SuppressionList.SearchResult{
          results: mapped_results,
          links: body.links,
          total_count: body.total_count
        }
      _ -> response
    end
  end
end
