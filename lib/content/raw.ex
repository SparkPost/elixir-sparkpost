defmodule SparkPost.Content.Raw do
  @moduledoc """
  Raw message content, formatted as per [RFC2822](http://www.faqs.org/rfcs/rfc822.html).

  Designed for use in `%SparkPost.Transmission{content: ...}`.

  ## Fields
   - email_rfc822: raw message body
  """

  defstruct email_rfc822: :required
end
