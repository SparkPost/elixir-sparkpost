defmodule SparkPost.Event do
  @moduledoc """
  Defines actions for the events endpoint

  https://developers.sparkpost.com/api/events/
  """
  alias SparkPost.{Endpoint, Event}

  @type params :: %{
          optional(:ab_test_versions) => String.t(),
          optional(:ab_tests) => String.t(),
          optional(:bounce_classes) => String.t(),
          optional(:campaigns) => String.t(),
          optional(:cursor) => String.t(),
          optional(:delimiter) => String.t(),
          optional(:event_ids) => String.t(),
          optional(:events) => String.t(),
          optional(:from_addresses) => String.t(),
          optional(:from) => String.t(),
          optional(:ip_pools) => String.t(),
          optional(:messages) => String.t(),
          optional(:per_page) => integer,
          optional(:reasons) => String.t(),
          optional(:recipient_domains) => String.t(),
          optional(:recipients) => String.t(),
          optional(:sending_domains) => String.t(),
          optional(:sending_ips) => String.t(),
          optional(:subaccounts) => String.t(),
          optional(:subjects) => String.t(),
          optional(:templates) => String.t(),
          optional(:to) => String.t(),
          optional(:transmissions) => String.t()
        }

  @doc """
  Search for message events

  https://developers.sparkpost.com/api/events/#events-get-search-for-message-events

  Does not sanitize parameters in any way. If a parameter is specified as needing
  to be a comma-separated string, then it needs to be sent as such.
  """
  @spec search_message_events(params) :: Event.SearchResult.t() | Endpoint.Error.t()
  def search_message_events(%{} = params \\ %{}) do
    response = Endpoint.request(:get, "events/message", %{}, %{}, [params: params], false)

    case response do
      %SparkPost.Endpoint.Response{results: body} ->
        %SparkPost.Event.SearchResult{
          results: body.results,
          links: body.links,
          total_count: body.total_count
        }

      _ ->
        response
    end
  end
end
