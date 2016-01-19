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

  @doc """
  Convenience conversions to `[ %SparkPost.Recipient{} ]` from:
   - email string
   - `%{list_id: ...}`
   - list of email strings
   - list of `%{address: ...}`
  """
  def to_recipient_list(email_list) when is_list(email_list) do
    Enum.map(email_list, fn (recip) -> to_recipient(recip)
    end)
  end

  def to_recipient_list(email) when is_binary(email) do
    [ to_recipient(email) ]
  end

  def to_recipient_list(%{list_id: list_id}) do
    %SparkPost.Recipient.ListRef{list_id: list_id}
  end

  @doc """
  Convenience conversions to `%SparkPost.Recipient{}` from:
   - email string
   - `%{address: ...}`
  """
  def to_recipient(email) when is_binary(email) do
    %__MODULE__{ address: %SparkPost.Address{ email: email }}
  end

  def to_recipient(struc) when is_map(struc) do
    struct(SparkPost.Recipient, %{
      struc | address: SparkPost.Address.to_address(struc.address),
    })
  end
end
