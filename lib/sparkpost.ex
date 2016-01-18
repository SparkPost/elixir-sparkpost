defmodule Sparkpost do
  alias Sparkpost.Transmission
  alias Sparkpost.Content
  alias Sparkpost.Recipient

  def send(to: recip, from: sender, subject: subject, text: text, html: html) do
    Transmission.create(%Transmission{
      options: %Transmission.Options{},
      recipients: Recipient.to_recipient_list(recip),
      return_path: sender,
      content: %Content.Inline{
        subject: subject,
        from: %Sparkpost.Address{ email: sender },
        text: text,
        html: html
      }
    })
  end
end
