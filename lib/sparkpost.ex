defmodule SparkPost do
  @moduledoc """
  This is the Elixir [SparkPost](https://www.sparkpost.com/) client library.

  To begin using SparkPost, check out `Sparkpost.send/5`

      iex> h SparkPost.send

    You can also dive straight into the `Sparkpost.Transmission` docs:

      iex> h SparkPost.Transmission

    More detailed information about this library is available in README.md and you can 
    learn about the SparkPost API itself from the
    [reference docs](https://www.sparkpost.com/api).
  """

  alias SparkPost.{Address, Content, Transmission}

  @doc """
  A simple email sending function based on the SparkPost API.

  ## Parameters
   - to: recipient email address 
   - from: sender email address
   - subject: email subject line
   - text: plain text version of your email
   - html: HTML formatted version of your email

  ## Example
      iex> SparkPost.send
        to: "you@there.com",
        from: "me@here.com",
        subject: "My first Elixir email", 
        text: "This is the boring version of the email body",
        html: "This is the <strong>tasty</strong> <em>rich</em> version of the <a href=\"https://www.sparkpost.com/\">email</a> body."
  """
  def send(to: recip, from: sender, subject: subject, text: text, html: html) do
    Transmission.send(%Transmission{
      recipients: recip,
      return_path: Address.to_address(sender).email,
      content: %Content.Inline{
        subject: subject,
        from: sender,
        text: text,
        html: html
      }
    })
  end
end
