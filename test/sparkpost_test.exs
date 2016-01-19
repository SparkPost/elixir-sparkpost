defmodule SparkPostTest do
  use ExUnit.Case

  alias SparkPost.MockServer
  alias SparkPost.Recipient
  alias SparkPost.Content
  alias SparkPost.Address

  import Mock

  test "send succeeds with a Transmission.Response" do
    with_mock HTTPotion, [request: MockServer.mk_resp] do
      resp = SparkPost.send(
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
    with_mock HTTPotion, [request: MockServer.mk_fail] do
      resp = SparkPost.send(
        to: "you@there.com",
        from: nil,
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
    with_mock HTTPotion, [request: fn (method, url, opts) ->
      inreq = Poison.decode!(opts[:body], [keys: :atoms])
      assert Recipient.to_recipient_list(inreq.recipients) == Recipient.to_recipient_list(to)
      assert Content.to_content(inreq.content) == %Content.Inline{
        from: Address.to_address(from),
        subject: subject,
        text: text,
        html: html
      }
      MockServer.mk_resp.(method, url, opts)
    end] do
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
