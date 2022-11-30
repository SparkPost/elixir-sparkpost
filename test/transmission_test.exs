defmodule SparkPost.TransmissionTest do
  @moduledoc false
  use ExUnit.Case

  alias SparkPost.{
    Address,
    Content,
    MockServer,
    Recipient,
    Transmission
  }

  import Mock

  defmodule TestStructs do
    @moduledoc false
    def skeleton(options: options, recipients: recipients, content: content) do
      %Transmission{
        options: options,
        recipients: recipients,
        return_path: "from@me.com",
        content: content
      }
    end

    def full_addr_recipient(fulladdr) when is_binary(fulladdr) do
      case Regex.run(~r/\s*(.+)\s+<(.+@.+)>\s*$/, fulladdr) do
        [_, name, addr] -> full_addr_recipient(name, addr)
        true -> raise "Invalid email address: #{fulladdr}"
      end
    end

    def full_addr_recipient(name \\ "You There", email \\ "you@there.com") do
      %Recipient{address: %Address{name: name, email: email}}
    end

    def addr_spec_recipient(email \\ "you@there.com") do
      %Recipient{address: %Address{email: email}}
    end

    def inline_content do
      %Content.Inline{
        subject: "Subject line",
        from: %Address{email: "from@me.com"},
        text: "text content",
        html: "html content"
      }
    end

    def basic_transmission do
      skeleton(
        options: %Transmission.Options{},
        recipients: [full_addr_recipient()],
        content: inline_content()
      )
    end
  end

  defmodule TestRequests do
    @moduledoc false
    def test_send(req, test_fn) do
      with_mock HTTPoison,
        request: handle_send(test_fn) do
        Transmission.send(req)
      end
    end

    defp handle_send(response_test_fn) do
      fn method, url, body, headers, opts ->
        req = Poison.decode!(body, %{keys: :atoms})

        fullreq =
          struct(Transmission, %{
            req
            | options: struct(Transmission.Options, req.options),
              recipients: parse_recipients_field(req.recipients),
              content: Content.to_content(req.content)
          })

        response_test_fn.(fullreq)
        MockServer.mk_resp().(method, url, body, headers, opts)
      end
    end

    defp parse_recipients_field(lst) when is_list(lst) do
      Enum.map(lst, fn recip ->
        struct(Recipient, parse_recipient(recip))
      end)
    end

    defp parse_recipients_field(%{list_id: _} = listref) do
      struct(Recipient.ListRef, listref)
    end

    defp parse_recipient(%{address: addr} = recip) do
      %{recip | address: parse_address(addr)}
    end

    defp parse_address(%{name: name, email: email}) do
      %Address{name: name, email: email}
    end

    defp parse_address(%{email: email}) do
      %Address{email: email}
    end
  end

  test "Transmission.send succeeds with Transmission.Response" do
    with_mock HTTPoison, request: MockServer.mk_resp() do
      resp = Transmission.send(TestStructs.basic_transmission())
      assert %Transmission.Response{} = resp
    end
  end

  test "Transmission.send fails with Endpoint.Error" do
    with_mock HTTPoison, request: MockServer.mk_fail() do
      req = TestStructs.basic_transmission()
      resp = Transmission.send(req)
      assert %SparkPost.Endpoint.Error{} = resp
    end
  end

  test "Transmission.send emits a POST" do
    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert method == :post
        MockServer.mk_resp().(method, url, body, headers, opts)
      end do
      Transmission.send(TestStructs.basic_transmission())
    end
  end

  test "Transmission.send marshals options correctly" do
    transopts = %Transmission.Options{
      open_tracking: true,
      click_tracking: false,
      transactional: true,
      sandbox: false,
      skip_suppression: false
    }

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | options: transopts},
      &assert(&1.options == transopts)
    )
  end

  test "Transmission.send marshals inline recipients correctly" do
    recipients = [
      TestStructs.full_addr_recipient("You There", "you@there.com"),
      TestStructs.full_addr_recipient("Them There", "them@there.com")
    ]

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | recipients: recipients},
      &assert(&1.recipients == recipients)
    )
  end

  test "Transmission.send accepts a list of long-form recipient email addresses" do
    # RFC2822 3.4: Address Specification
    recipients = ["You There <you@there.com>", "You Too There <youtoo@theretoo.com>"]

    expected =
      Enum.map(recipients, fn recip ->
        TestStructs.full_addr_recipient(recip)
      end)

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | recipients: recipients},
      &assert(&1.recipients == expected)
    )
  end

  test "Transmission.send accepts a list of short-form recipient email addresses" do
    # RFC2822 3.4.1: Addr-spec specification
    recipients = ["you@there.com", "youtoo@theretoo.com"]

    expected =
      Enum.map(recipients, fn recip ->
        TestStructs.addr_spec_recipient(recip)
      end)

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | recipients: recipients},
      &assert(&1.recipients == expected)
    )
  end

  test "Transmission.send accepts a mixed list recipient addresses" do
    recip0 = "You There <you@there.com>"
    recip1 = "youtoo@theretoo.com"
    recip2 = %Address{name: "You Also", email: "you@also.com"}
    recip3 = %{name: "And You", email: "and@you.com"}
    recip4 = %{email: "me@too.com"}
    recipients = [recip0, recip1, recip2, recip3, recip4]

    expected = [
      TestStructs.full_addr_recipient(recip0),
      TestStructs.addr_spec_recipient(recip1),
      %Recipient{address: recip2},
      %Recipient{address: %Address{name: recip3.name, email: recip3.email}},
      %Recipient{address: %Address{email: recip4.email}}
    ]

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | recipients: recipients},
      &assert(&1.recipients == expected)
    )
  end

  test "Transmission.send requires correctly-formatted email addresses" do
    assert_raise Address.FormatError, fn ->
      TestRequests.test_send(
        %{TestStructs.basic_transmission() | recipients: "paula and paul"},
        & &1
      )
    end
  end

  test "Transmission.send marshals recipient lists correctly" do
    recip_lst = %Recipient.ListRef{list_id: "list101"}

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | recipients: recip_lst},
      &assert(&1.recipients == recip_lst)
    )
  end

  test "Transmission.send marshals inline raw content correctly" do
    content = %Content.Raw{
      email_rfc822:
        "Content-Type: text/plain\r\nTo: \"{{address.name}}\" <{{address.email}}>\r\n\r\n We are testing Elixir and SparkPost together\r\n"
    }

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | content: content},
      &assert(&1.content == content)
    )
  end

  test "Transmission.send marshals inline text/html content correctly" do
    content = %Content.Inline{
      from: "me@here.com",
      subject: "Testing SparkPost and Elixir",
      text: "We all live in a transient theoretical construct"
    }

    expected = %Content.Inline{
      from: %Address{email: "me@here.com"},
      subject: "Testing SparkPost and Elixir",
      text: "We all live in a transient theoretical construct"
    }

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | content: content},
      &assert(&1.content == expected)
    )
  end

  test "Transmission.send marshals template references correctly" do
    content = %Content.TemplateRef{
      template_id: "template101",
      use_draft_template: true
    }

    TestRequests.test_send(
      %{TestStructs.basic_transmission() | content: content},
      &assert(&1.content == content)
    )
  end

  test "Transmission.list succeeds with a list of Transmission" do
    with_mock HTTPoison, request: MockServer.mk_list() do
      resp = Transmission.list()
      assert is_list(resp)
      Enum.each(resp, fn r -> assert %Transmission{} = r end)
    end
  end

  test "Transmission.list fails with Endpoint.Error" do
    with_mock HTTPoison, request: MockServer.mk_fail() do
      resp = Transmission.list()
      assert %SparkPost.Endpoint.Error{} = resp
    end
  end

  test "Transmission.list emits a GET" do
    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert method == :get
        MockServer.mk_list().(method, url, body, headers, opts)
      end do
      Transmission.list()
    end
  end

  test "Transmission.get succeeds with a Transmission" do
  end

  test "Transmission.get emits a GET" do
    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        assert method == :get
        MockServer.mk_get().(method, url, body, headers, opts)
      end do
      Transmission.get("TRANSMISSION_ID")
    end
  end
end
