defmodule SparkPost.Template.Response do
  @moduledoc """
  The response generated when SparkPost receives a Template request.

  Returned by `SparkPost.Template.create/1`

  ## Fields
   - id: Unique id of the template, generated automatically or specified as part of the original request
  """

  defstruct id: nil
end
