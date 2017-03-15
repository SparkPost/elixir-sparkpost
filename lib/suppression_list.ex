defmodule SparkPost.SuppressionList do
  @moduledoc """
  The SparkPost Suppression List API for working with suppression lists.
  Use `SparkPost.SupressionList.search/1` to search through your account's suppression list.

  Check out the documentation for each function
  or use the [SparkPost API reference](https://developers.sparkpost.com/api/suppression_list.html) for details.

  Returned by `SparkPost.SupressionList.search/1`.
    - %SparkPost.SuppressionList.SearchResult{}
  """

  alias SparkPost.Endpoint

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
    :get
    |> Endpoint.request("suppression-list", %{}, %{}, [params: params])
    |> Endpoint.marshal_response(SparkPost.SuppressionList.SearchResult)
  end
end
