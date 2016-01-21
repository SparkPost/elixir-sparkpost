defmodule SparkPost.Transmission.Response do
  @moduledoc """
  The response generated when SparkPost receives a Transmission request.

  Returned by `SparkPost.Transmision.send/1`

  ## Fields
   - total_accepted_recipients: count of recipients which SparkPost accepted for delivery
   - total_rejected_recipients: count of recipients which SparkPost rejected
  """

  defstruct id: nil,
    total_accepted_recipients: nil,
    total_rejected_recipients: nil
end
