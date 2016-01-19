defmodule SparkPost.Address do
  @moduledoc """
  An long-form email address with both name and address parts.

  e.g.: Sparky McSparkPost <sparky@sparkpost.com>

  Designed for use in:
   - `%SparkPost.Content.Inline{from: ...}`
   - `%SparkPost.Recipient.address{from: ...}`
  """

  defstruct name: nil, email: :required

  @doc """
  Convenience conversions to `%SparkPost.Address{}` from:
    - email address string
    - `%{name: ..., email: ...}`
  """
  def to_address(email) when is_binary(email) do
    %__MODULE__{email: email}
  end
  def to_address(struc) when is_map(struc) do
    struct(__MODULE__, struc)
  end
end
