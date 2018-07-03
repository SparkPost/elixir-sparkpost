defmodule SparkPost.TemplateTest do
  use ExUnit.Case, async: false

  alias SparkPost.Content.{TemplateRef, Inline}
  alias SparkPost.{Endpoint, MockServer, Template}

  import Mock

  defmodule TestStruct do
    def basic_template do
      %SparkPost.Template{id: "TEMPLATE_ID"}
    end

    def basic_template_ref do
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
      resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
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
      resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
      assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.preview unmarshals complex from field correctly", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
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
      resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
      assert %SparkPost.Address{
        name: nil,
        "email": "marketing@bounces.company.example"
      } == resp.from
  end

  test_with_mock "Template.create succeeds with Template.Response", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :post
      assert url =~ "/templates"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("createtemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      assert Template.create(TestStruct.basic_template()) ==
        %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.create fails with Endpoint.Error", HTTPoison,
    [request: MockServer.mk_fail] do
      resp = Template.create(TestStruct.basic_template())
      assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.update succeeds with Template.Response", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :put
      assert url =~ "/templates/TEMPLATE_ID"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      assert Template.update(TestStruct.basic_template()) ==
        %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.update succeeds with update_published set", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :put
      assert url =~ "/templates/TEMPLATE_ID?update_published=true"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      assert Template.update(TestStruct.basic_template(), update_published: true) ==
        %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.update ignores update_published set if published field set", HTTPoison,
    [request: fn (method, url, body, headers, opts) ->
      assert method == :put
      refute url =~ "/templates/TEMPLATE_ID?update_published=true"
      assert url =~ "/templates/TEMPLATE_ID"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end] do
      template = %{TestStruct.basic_template() | published: true}
      assert Template.update(template , update_published: true) == %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end


  test_with_mock "Template.update fails with Endpoint.Error", HTTPoison,
    [request: MockServer.mk_fail] do
      resp = Template.update(TestStruct.basic_template())
      assert %Endpoint.Error{} = resp
  end
end
