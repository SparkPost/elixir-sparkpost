defmodule SparkPost.Content.Attachment do
  @moduledoc """
  File attachment.

  Designed for use in `%SparkPost.Content.Inline{attachments: ...}` and
  `%SparkPost.Content.Inline{inline_images: ...}`.

  ## Fields
   - name: filename
   - type: MIME type
   - data: binary file content
  """

  defstruct name: :required, type: :required, data: :required
end
