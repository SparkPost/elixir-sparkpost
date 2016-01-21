defmodule SparkPost.Address.FormatError do
  @moduledoc """
  Raised by Address.to_address/1 when an invalid email address is detected.

  ## Fields
   - message: human-readable error message
  """
  defexception message: nil
end
