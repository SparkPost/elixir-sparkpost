defmodule Sparkpost.Address do
  defstruct name: nil, email: :required

  def to_address(email) when is_binary(email) do
    %__MODULE__{email: email}
  end

  def to_address(struc) when is_map(struc) do
    struct(__MODULE__, struc)
  end
end
