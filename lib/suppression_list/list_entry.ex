defmodule SparkPost.SuppressionList.ListEntry do
  @moduledoc """
  SparkPost representation of a suppression list entry.

  ## Fields
   - recipient: Email address that was suppressed
   - type: Type of suppression record (transactional or non_transactional)
   - source: Source responsible for inserting the list entry. Can be one of
      "Spam Complaint", "List Unsubscribe", "Bounce Rule", "Unsubscribe Link",
      "Manually Added", or "Compliance"
   - description: explanation of suppression
  """

  defstruct recipient: :required,
    type: :required,
    source: nil,
    description: nil,
    transactional: nil,
    non_transactional: nil
end
