defmodule SparkPost.Recipient.FormatError do
  @moduledoc """
  Raised by Recipient.to_recipient/1 when an invalid email addrss is detected.

  ## Fields
   - message: human-readable error message
  """
  defexception message: nil
end
