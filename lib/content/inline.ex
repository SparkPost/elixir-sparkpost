defmodule SparkPost.Content.Inline do
  @moduledoc """
  Inline message content.

  Designed for use in `%SparkPost.Transmission{content: ...}`.

  ## Fields
   - from: 'From' address (email string | `%SparkPost.Address`)
   - reply_to: the destination for replies to this message aka `Reply-To` (email string)
   - headers: email headers (map)
   - subject: email subject line
   - text: plain text message body
   - html: HTML-formatted message body
   - attachments: file attachments (list of `%SparkPost.Content.Attachment`)
   - inline_images: inline images (list of `%SparkPost.Content.Attachment`)

  Note: at least one of `text` or `html` must be filled out.
  """

  defstruct from: :required,
    reply_to: nil,
    headers: nil,
    subject: :required,
    text: nil,
    html: nil,
    attachments: nil,
    inline_images: nil
end
