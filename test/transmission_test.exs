defmodule Sparkpost.TransmissionTest do
  use ExUnit.Case

  alias Sparkpost.Transmission
  alias Sparkpost.Recipient
  alias Sparkpost.Address
  alias Sparkpost.Content

  alias Sparkpost.MockServer

  import Mock

  defmodule TestStructs do
    def skeleton(options: options, recipients: recipients, content: content) do
      %Transmission{
        options: options,
        recipients: recipients,
        return_path: "from@me.com",
        content: content
      }
    end

    def inline_recipient do
      [ %Recipient{ address: %Address{ email: "to@you.com" }} ]
    end

    def inline_content do
      %Content.Inline{
          subject: "Subject line",
          from: %Address{ email: "from@me.com" },
          text: "text content",
          html: "html content"
        }
    end

    def basic_transmission do
      skeleton(
        options: %Transmission.Options{},
        recipients: inline_recipient,
        content: inline_content
      )
    end
  end

  defmodule TestRequests do
    def test_create(req, test_fn) do
      with_mock HTTPotion, [
        request: handle_create(test_fn)
      ] do
        Transmission.create(req)
      end
    end

    defp handle_create(response_test_fn) do
      fn (method, url, opts) ->
        req = Poison.decode!(opts[:body], [keys: :atoms])
        fullreq = struct(Transmission, %{
          req |
          options: struct(Transmission.Options, req.options),
          recipients: Recipient.to_recipient_list(req.recipients),
          content: Content.to_content(req.content)
        })
        response_test_fn.(fullreq)
        MockServer.mk_resp.(method, url, opts)
      end
    end
  end

  test "Transmission.create succeeds with Transmission.Response" do
    with_mock HTTPotion, [request: MockServer.mk_resp] do
      resp = Transmission.create(TestStructs.basic_transmission)
      assert %Transmission.Response{} = resp
    end
  end

  test "Transmission.create fails with Endpoint.Error" do
    with_mock HTTPotion, [request: MockServer.mk_fail] do
      resp = Transmission.create(TestStructs.basic_transmission)
      assert %Sparkpost.Endpoint.Error{} = resp
    end
  end

  test "Transmission.create emits a POST" do
    with_mock HTTPotion, [request: fn (method, url, opts) ->
      assert method == :post
      MockServer.mk_resp.(method, url, opts)
    end] do
      Transmission.create(TestStructs.basic_transmission)
    end
  end

  test "Transmission.create marshals options correctly" do
    transopts = %Transmission.Options{
      open_tracking: true,
      click_tracking: false,
      transactional: true,
      sandbox: false,
      skip_suppression: false
    }
    TestRequests.test_create(
      %{TestStructs.basic_transmission | options: transopts},
      &(assert &1.options == transopts)
    )
  end

  test "Transmission.create marshals inline recipients correctly" do
    recipients = Recipient.to_recipient_list(["to@you.com", "to@them.com"])
    TestRequests.test_create(
      %{TestStructs.basic_transmission | recipients: recipients},
      &(assert &1.recipients == recipients)
    )
  end

  test "Transmission.create marshals recipient lists correctly" do
    recip_lst = %Recipient.ListRef{list_id: "list101"}
    TestRequests.test_create(
      %{TestStructs.basic_transmission | recipients: recip_lst},
      &(assert &1.recipients == recip_lst)
    )
  end

  test "Transmission.create marshals inline raw content correctly" do
    content = %Content.Raw{
      email_rfc822: "Content-Type: text/plain\r\nTo: \"{{address.name}}\" <{{address.email}}>\r\n\r\n We are testing Elixir and SparkPost together\r\n"
    }
    TestRequests.test_create(
      %{TestStructs.basic_transmission | content: content},
      &(assert &1.content == content)
    )
  end

  test "Transmission.create marshals inline text/html content correctly" do
    content = %Content.Inline{
      from: Address.to_address("me@here.com"),
      subject: "Testing Sparkpost and Elixir",
      text: "We all live in a transient theoretical construct"
    }
    TestRequests.test_create(
      %{TestStructs.basic_transmission | content: content},
      &(assert &1.content == content)
    )
  end

  test "Transmission.create marshals template references correctly" do
    content = %Content.TemplateRef{
      template_id: "template101",
      use_draft_template: true
    }
    TestRequests.test_create(
      %{TestStructs.basic_transmission | content: content},
      &(assert &1.content == content)
    )
  end

  test "Transmission.list succeeds with a list of Transmission" do
    with_mock HTTPotion, [request: MockServer.mk_list] do
      resp = Transmission.list
      assert is_list(resp)
      Enum.each(resp, fn r -> assert %Transmission{} = r end)
    end
  end

  test "Transmission.list fails with Endpoint.Error" do
    with_mock HTTPotion, [request: MockServer.mk_fail] do
      resp = Transmission.list
      assert %Sparkpost.Endpoint.Error{} = resp
    end
  end

  test "Transmission.list emits a GET" do
    with_mock HTTPotion, [request: fn (method, url, opts) ->
      assert method == :get
      MockServer.mk_list.(method, url, opts)
    end] do
      Transmission.list
    end
  end

  test "Transmission.get succeeds with a Transmission" do
  end

  test "Transmission.get emits a GET" do
    with_mock HTTPotion, [request: fn (method, url, opts) ->
      assert method == :get
      MockServer.mk_get.(method, url, opts)
    end] do
      Transmission.get("TRANSMISSION_ID")
    end
  end
end
