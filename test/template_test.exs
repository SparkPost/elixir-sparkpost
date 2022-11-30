defmodule SparkPost.TemplateTest do
  @moduledoc false
  use ExUnit.Case, async: false

  alias SparkPost.{Endpoint, MockServer, Template}
  alias SparkPost.Content.{Inline, TemplateRef}

  import Mock

  defmodule TestStruct do
    @moduledoc false
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

  describe "Template.list" do
    test_with_mock "returns list of templates", HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert method == :get
        assert url =~ "/templates"
        fun = MockServer.mk_http_resp(200, MockServer.get_json("listtemplate"))
        fun.(method, url, body, headers, opts)
      end do
      assert [%SparkPost.Template{}, %SparkPost.Template{}] = Template.list()
    end

    test_with_mock "passes :draft param", HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert opts[:params] == [draft: true]
        fun = MockServer.mk_http_resp(200, MockServer.get_json("listtemplate"))
        fun.(method, url, body, headers, opts)
      end do
      assert Template.list(%{draft: true})
    end

    test_with_mock "passes :shared_with_subaccounts param", HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert opts[:params] == [shared_with_subaccounts: false]
        fun = MockServer.mk_http_resp(200, MockServer.get_json("listtemplate"))
        fun.(method, url, body, headers, opts)
      end do
      assert Template.list(%{shared_with_subaccounts: false})
    end

    test_with_mock "returns error response", HTTPoison,
      request: fn method, url, body, headers, opts ->
        fun = MockServer.mk_error("Uknown")
        fun.(method, url, body, headers, opts)
      end do
      assert Template.list() == %SparkPost.Endpoint.Error{
               status_code: nil,
               errors: ["Uknown"],
               results: nil
             }
    end
  end

  test_with_mock "Template.preview succeeds with Content.Inline",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :post
                   # draft not set
                   assert String.ends_with?(url, "preview")
                   fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
                   fun.(method, url, body, headers, opts)
                 end do
    resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
    assert %Inline{} = resp
  end

  test_with_mock "Template.preview succeeds with Content.Inline and draft set",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :post
                   assert String.ends_with?(url, "preview?draft=true")
                   fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
                   fun.(method, url, body, headers, opts)
                 end do
    resp = Template.preview(TestStruct.template_with_draft(), TestStruct.substitution_data())
    assert %Inline{} = resp
  end

  test_with_mock "Template.preview fails with Endpoint.Error", HTTPoison,
    request: MockServer.mk_fail() do
    resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())
    assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.preview unmarshals complex from field correctly", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :post
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate"))
      fun.(method, url, body, headers, opts)
    end do
    resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())

    assert %SparkPost.Address{
             name: "Example Company Marketing",
             email: "marketing@bounces.company.example"
           } == resp.from
  end

  test_with_mock "Template.preview unmarshals simple from field correctly", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :post
      fun = MockServer.mk_http_resp(200, MockServer.get_json("previewtemplate_simpleemail"))
      fun.(method, url, body, headers, opts)
    end do
    resp = Template.preview(TestStruct.basic_template_ref(), TestStruct.substitution_data())

    assert %SparkPost.Address{
             name: nil,
             email: "marketing@bounces.company.example"
           } == resp.from
  end

  test_with_mock "Template.create succeeds with Template.Response", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :post
      assert url =~ "/templates"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("createtemplate"))
      fun.(method, url, body, headers, opts)
    end do
    assert Template.create(TestStruct.basic_template()) ==
             %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.create fails with Endpoint.Error", HTTPoison,
    request: MockServer.mk_fail() do
    resp = Template.create(TestStruct.basic_template())
    assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.update succeeds with Template.Response", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :put
      assert url =~ "/templates/TEMPLATE_ID"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end do
    assert Template.update(TestStruct.basic_template()) ==
             %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.update succeeds with update_published set", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :put
      assert url =~ "/templates/TEMPLATE_ID?update_published=true"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end do
    assert Template.update(TestStruct.basic_template(), update_published: true) ==
             %SparkPost.Template.Response{id: "TEMPLATE_ID"}
  end

  test_with_mock "Template.update ignores update_published set if published field set", HTTPoison,
    request: fn method, url, body, headers, opts ->
      assert method == :put
      refute url =~ "/templates/TEMPLATE_ID?update_published=true"
      assert url =~ "/templates/TEMPLATE_ID"
      fun = MockServer.mk_http_resp(200, MockServer.get_json("updatetemplate"))
      fun.(method, url, body, headers, opts)
    end do
    template = %{TestStruct.basic_template() | published: true}

    assert Template.update(template, update_published: true) == %SparkPost.Template.Response{
             id: "TEMPLATE_ID"
           }
  end

  test_with_mock "Template.update fails with Endpoint.Error", HTTPoison,
    request: MockServer.mk_fail() do
    resp = Template.update(TestStruct.basic_template())
    assert %Endpoint.Error{} = resp
  end

  test_with_mock "Template.delete succeeds with empty body",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :delete
                   assert url =~ "/templates/TEMPLATE_ID"
                   fun = MockServer.mk_http_resp(200, "{}")
                   fun.(method, url, body, headers, opts)
                 end do
    assert Template.delete("TEMPLATE_ID") ==
             {:ok, %SparkPost.Endpoint.Response{results: %{}, status_code: 200}}
  end

  test_with_mock "Template.delete fails with 404",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :delete
                   assert url =~ "/templates/TEMPLATE_ID"

                   fun =
                     MockServer.mk_http_resp(404, MockServer.get_json("templatedelete_fail_404"))

                   fun.(method, url, body, headers, opts)
                 end do
    assert {:error, %Endpoint.Error{} = resp} = Template.delete("TEMPLATE_ID")
    assert resp.status_code == 404

    assert resp.errors == [
             %{
               code: "1600",
               description: "Template does not exist",
               message: "resource not found"
             }
           ]
  end

  test_with_mock "Template.delete fails with 409",
                 HTTPoison,
                 request: fn method, url, body, headers, opts ->
                   assert method == :delete
                   assert url =~ "/templates/TEMPLATE_ID"

                   fun =
                     MockServer.mk_http_resp(409, MockServer.get_json("templatedelete_fail_409"))

                   fun.(method, url, body, headers, opts)
                 end do
    assert {:error, %Endpoint.Error{} = resp} = Template.delete("TEMPLATE_ID")
    assert resp.status_code == 409

    assert resp.errors == [
             %{
               code: "1602",
               description: "Template is in use by msg generation",
               message: "resource conflict"
             }
           ]
  end
end
