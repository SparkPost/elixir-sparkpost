defmodule SparkPost.SuppressionList.SearchResult do
  @moduledoc """
  SparkPost representation of a suppression list search result.

  ## Fields
   - results: List of %SparkPost.SuppressionList.ListEntry{} objects.
   - links: Links to the first query in the chain and next query to be made for cursor
      based pagination.
   - total_count: Total number of results across all pages based on the query params.
  """

  defstruct results: :required, links: :required, total_count: :required
end
