defmodule Washup.RequiredError do
  @moduledoc """
  Raised by Wash.verify/2 if a :required field is found.

  ## Fields
   - path: struct path to the error
   - message: human-readable error message
  """

  defexception path: nil, message: nil
end
