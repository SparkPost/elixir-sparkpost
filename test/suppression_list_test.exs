defmodule SparkPost.SuppressionListTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias SparkPost.{MockServer, SuppressionList}
  alias SparkPost.SuppressionList.{SearchResult, ListEntry}

  import Mock

  test_with_mock "SuppressionList.update_one succeeds with message",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :put
      fun = MockServer.mk_http_resp(200, MockServer.get_json("suppressionlistupdate"))
      fun.(method, url, body, headers, opts)
    end] do
    resp = SuppressionList.update_one("test@marketing.com", "non_transactional", "test description")
    assert resp == "Test response message"
  end

  test_with_mock "SuppressionList.update_one fails with invalid type",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :put
      fun = MockServer.mk_http_resp(400, MockServer.get_json("suppressionupdate_fail"))
      fun.(method, url, body, headers, opts)
    end] do
    resp = SuppressionList.update_one("test@marketing.com", "bad_type")
    assert %SparkPost.Endpoint.Error{} = resp
    assert resp.status_code == 400
    assert resp.errors == [%{message: "Type must be one of: 'transactional', 'non_transactional'"}]
  end

  test_with_mock "SuppressionList.delete succeeds with empty body",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :delete
      fun = MockServer.mk_http_resp(204, "")
      fun.(method, url, body, headers, opts)
    end] do
      resp = SuppressionList.delete("test@marketing.com")
      assert resp == ""
  end

  test_with_mock "SuppressionList.delete fails 404",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :delete
      fun = MockServer.mk_http_resp(404, MockServer.get_json("suppressiondelete_fail"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = SuppressionList.delete("test@marketing.com")
      assert %SparkPost.Endpoint.Error{} = resp
      assert resp.status_code == 404
      assert resp.errors == [%{message: "Recipient could not be found"}]
  end

  test_with_mock "SuppressionList.search succeeds with SuppressionList.SearchResult",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :get
      fun = MockServer.mk_http_resp(200, MockServer.get_json("suppressionsearch"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = SuppressionList.search()
      assert %SearchResult{} = resp
  end

  test_with_mock "SuppressionList.search fails with Endpoint.Error", HTTPoison,
    [request: MockServer.mk_fail] do
      resp = SuppressionList.search()
      assert %SparkPost.Endpoint.Error{} = resp
  end

  test_with_mock "SuppressionList.search creates ListEntry structs", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :get
      fun = MockServer.mk_http_resp(200, MockServer.get_json("suppressionsearch"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = SuppressionList.search()
      assert %SearchResult{
        results: [
          %ListEntry{
            recipient: "test@marketing.com",
            type: "non_transactional",
            source: nil,
            description: nil,
            non_transactional: nil
          }
        ],
        links: [],
        total_count: 1
      } == resp
  end

  test_with_mock "SuppressionList.search parses out cursor info", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :get
      fun = MockServer.mk_http_resp(200, MockServer.get_json("suppressionsearch_links"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = SuppressionList.search()
      assert %SearchResult{
        results: [
          %ListEntry{
            recipient: "test@marketing.com",
            type: "non_transactional",
            source: nil,
            description: nil,
            non_transactional: nil
          }
        ],
        links: [
          %{href: "/currentlink", rel: "first"},
          %{href: "/linkwithcursor", rel: "next"}
        ],
        total_count: 1
      } == resp
  end
end
