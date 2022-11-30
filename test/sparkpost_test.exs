defmodule SparkPostTest do
  @moduledoc false
  use ExUnit.Case

  alias SparkPost.{Address, Content, MockServer, Recipient}

  import Mock

  test "send succeeds with a Transmission.Response" do
    with_mock HTTPoison, request: MockServer.mk_resp() do
      resp =
        SparkPost.send(
          to: "you@there.com",
          from: "me@here.com",
          subject: "Elixir and SparkPost...",
          text: "Raw text email is boring",
          html: "<marquee>Rich text email is terrifying</marquee>"
        )

      assert %SparkPost.Transmission.Response{} = resp
    end
  end

  test "send fails with a Endpoint.Error" do
    with_mock HTTPoison, request: MockServer.mk_fail() do
      resp =
        SparkPost.send(
          to: "you@there.com",
          from: "me@here.com",
          subject: "Elixir and SparkPost...",
          text: nil,
          html: nil
        )

      assert %SparkPost.Endpoint.Error{} = resp
    end
  end

  test "send marshals arguments correctly" do
    from = "me@here.com"
    to = "you@there.com"
    subject = "Elixir and SparkPost..."
    text = "Raw text email is boring"
    html = "<marquee>Rich text email is terrifying</marquee>"

    with_mock HTTPoison,
      request: fn method, url, body, headers, opts ->
        inreq = Poison.decode!(body, %{keys: :atoms})
        assert Recipient.to_recipient_list(inreq.recipients) == Recipient.to_recipient_list(to)

        assert Content.to_content(inreq.content) == %Content.Inline{
                 from: Address.to_address(from),
                 subject: subject,
                 text: text,
                 html: html
               }

        MockServer.mk_resp().(method, url, body, headers, opts)
      end do
      SparkPost.send(
        to: to,
        from: from,
        subject: subject,
        text: text,
        html: html
      )
    end
  end
end
