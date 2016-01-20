defmodule SparkPost.Recipient do
  @moduledoc """
  A single recipient.

  Designed for use in `SparkPost.Transmission{recipients: ...}`.

  ## Fields
   - return_path: `Return-Path` address (email string)
   - tags: user-specified per-recipient tags (list of string)
   - metadata: user-specified per-recipient metadata (map)
   - substitution_data: personalisation fields for use in the message body (map)
  """

  defstruct address: :required,
    return_path: nil,
    tags: nil,
    metadata: nil,
    substitution_data: nil

  alias SparkPost.{Recipient, Address}

  @doc """
  Convenience conversions to `[ %SparkPost.Recipient{} ]` from:
   - `%{list_id: ...}`
   - mixed list of email strings, %SparkPost.Address structs, %{address: ...} and %{name: ..., email: ...}
  """
  def to_recipient_list(%{list_id: list_id}) do
    %Recipient.ListRef{list_id: list_id}
  end

  def to_recipient_list(email_list) when is_list(email_list) do
    Enum.map(email_list, fn (recip) -> to_recipient(recip)
    end)
  end

  def to_recipient_list(email) when is_binary(email) do
    [ to_recipient(email) ]
  end

  @doc """
  Convenience conversions to `%SparkPost.Recipient{}` from:
   - short form email string (e.g. "you@there.com")
   - long form email string (e.g. "You There <you@there.com>")
   - `%{address: ...}`
   - `%SparkPost.Address{}`
  """
  def to_recipient(addr) when is_binary(addr) do
    case Regex.run(~r/\s*(.+)\s+<(.+@.+)>\s*$/, addr) do
      [_, name, email] -> %__MODULE__{ address: %Address{ name: name, email: email }}
      nil -> case Regex.run(~r/\s*(.+@.+)\s*$/, addr) do
        [_, email] -> %__MODULE__{ address: %Address{ email: email }}
        nil -> raise Recipient.FormatError, message: "Invalid email address: #{addr}"
      end
    end
  end

  def to_recipient(%__MODULE__{} = recip) do
    recip
  end

  def to_recipient(%Address{} = recip) do
    %__MODULE__{address: recip}
  end

  def to_recipient(%{address: address} = struc) do
    struct(__MODULE__, %{
      struc | address: Address.to_address(address)
    })
  end

  def to_recipient(%{name: _name, email: _email} = struc) do
    %__MODULE__{ address: Address.to_address(struc) }
  end

  def to_recipient(%{email: _} = struc) do
    %__MODULE__{ address: Address.to_address(struc) }
  end
end
