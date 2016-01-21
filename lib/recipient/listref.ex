defmodule SparkPost.Recipient.ListRef do
  @moduledoc """
  Reference to a stored recipient list.

  Designed for use with `%SparkPost.Transmission{recipients: ...}`.

  ## Fields
   - list_id: recipient list identifier (string)
  """

  defstruct list_id: :required
end
