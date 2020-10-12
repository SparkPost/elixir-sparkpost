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
    parse_address(email)
  end

  def to_address(%{name: name, email: email}) do
    %__MODULE__{name: name, email: email}
  end

  def to_address(%{email: email}) do
    %__MODULE__{email: email}
  end

  defp parse_address(addr) when is_binary(addr) do
    case Regex.run(~r/\s*(.+)\s+<(.+@.+)>\s*$/, addr) do
      [_, name, email] ->
        %__MODULE__{name: name, email: email}

      nil ->
        case Regex.run(~r/\s*(.+@.+)\s*$/, addr) do
          [_, email] -> %__MODULE__{email: email}
          nil -> raise __MODULE__.FormatError, message: "Invalid email address: #{addr}"
        end
    end
  end
end
