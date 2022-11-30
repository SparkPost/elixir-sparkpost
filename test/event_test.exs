defmodule SparkPost.EventTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias SparkPost.{Event, MockServer}

  import Mock

  test_with_mock "Event.search_message_events/1 succeeds with Event.SearchResult",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :get

                   fun =
                     MockServer.mk_http_resp(
                       200,
                       MockServer.get_json("event.search_message_events")
                     )

                   fun.(method, url, body, headers, opts)
                 end do
    assert %Event.SearchResult{
             results: [_],
             links: %{},
             total_count: 1
           } = Event.search_message_events()
  end
end
