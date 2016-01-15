defmodule Sparkpost.Recipient do
  defstruct address: :required,
    return_path: nil,
    tags: nil,
    metadata: nil,
    substitution_data: nil

  defmodule ListRef do
    defstruct list_id: :required
  end

  def to_recipient_list(email_list) when is_list(email_list) do
    Enum.map(email_list, fn (recip) -> to_recipient(recip)
    end)
  end

  def to_recipient_list(email) when is_binary(email) do
    [ to_recipient(email) ]
  end

  def to_recipient(email) when is_binary(email) do
    %__MODULE__{ address: %Sparkpost.Address{ email: email }}
  end
end
