defmodule SparkpostTest do
  use ExUnit.Case

  alias Sparkpost.MockServer
  alias Sparkpost.Recipient
  alias Sparkpost.Content
  alias Sparkpost.Address

  import Mock

  test "send succeeds with a Transmission.Response" do
    with_mock HTTPotion, [request: MockServer.mk_resp] do
      resp = Sparkpost.send(
        to: "you@there.com",
        from: "me@here.com",
        subject: "Elixir and Sparkpost...",
        text: "Raw text email is boring",
        html: "<marquee>Rich text email is terrifying</marquee>"
      )
      assert %Sparkpost.Transmission.Response{} = resp
    end
  end

  test "send fails with a Endpoint.Error" do
    with_mock HTTPotion, [request: MockServer.mk_fail] do
      resp = Sparkpost.send(
        to: "you@there.com",
        from: nil,
        subject: "Elixir and Sparkpost...",
        text: nil,
        html: nil
      )
      assert %Sparkpost.Endpoint.Error{} = resp
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
      Sparkpost.send(
        to: to,
        from: from,
        subject: subject,
        text: text,
        html: html
      )
    end
  end
end
