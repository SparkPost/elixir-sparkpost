defmodule SparkPost.TemplateTest do
  use ExUnit.Case, async: false

  alias SparkPost.Content.{TemplateRef, Inline}
  alias SparkPost.{Endpoint, MockServer, Template}

  import Mock

  defmodule TestStruct do
    def basic_template do
      %TemplateRef{template_id: "TEMPLATE_ID", use_draft_template: nil}
    end

    def template_with_draft do
      %TemplateRef{template_id: "TEMPLATE_ID", use_draft_template: true}
    end

    def substitution_data do
      %{
        key1: "value1",
        key2: "value2"
      }
    end
  end

  test_with_mock "Template.preview succeeds with Content.Inline",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      # draft not set
      assert String.ends_with?(url, "preview")
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = Template.preview(TestStruct.basic_template(), TestStruct.substitution_data())
      assert %Inline{} = resp
  end

  test_with_mock "Template.preview succeeds with Content.Inline and draft set",
    HTTPoison, [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      assert String.ends_with?(url, "preview?draft=true")
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = Template.preview(TestStruct.template_with_draft(), TestStruct.substitution_data())
      assert %Inline{} = resp
  end

  test_with_mock "Template.preview fails with Endpoint.Error", HTTPoison,
    [request: MockServer.mk_fail] do
      resp = Template.preview(TestStruct.basic_template(), TestStruct.substitution_data())
      assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.preview unmarshals complex from field correctly", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = Template.preview(TestStruct.basic_template(), TestStruct.substitution_data())
      assert %SparkPost.Address{
        name: "Example Company Marketing",
        "email": "marketing@bounces.company.example"
      } == resp.from
  end

  test_with_mock "Template.preview unmarshals simple from field correctly", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate_simpleemail"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = Template.preview(TestStruct.basic_template(), TestStruct.substitution_data())
      assert %SparkPost.Address{
        name: nil,
        "email": "marketing@bounces.company.example"
      } == resp.from
  end
end
