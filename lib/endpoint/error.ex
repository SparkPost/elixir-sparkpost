defmodule SparkPost.Endpoint.Error do
  @moduledoc """
  Error raised by `SparkPost.Endpoint.request/3` when SparkPost returns a response
  containing an 'errors' key.

  ## Fields
   - status_code: HTTP status code
   - errors: list of SparkPost errors
   - results: API call results
  """

  defstruct status_code: nil, errors: nil, results: nil

  @type t :: %__MODULE__{}
end
