defmodule SparkPost.Event.SearchResult do
  @moduledoc """
  Defines structure for an event search request response

  The same response structure applies when searching for message and ingest events.

  https://developers.sparkpost.com/api/events/#events-get-search-for-message-events
  https://developers.sparkpost.com/api/events/#events-get-search-for-ingest-events
  """

  defstruct [
    :links,
    :results,
    :total_count
  ]

  @type t :: %__MODULE__{
          results: list(map),
          total_count: integer(),
          links: %{
            optional(:next) => String.t()
          }
        }
end
