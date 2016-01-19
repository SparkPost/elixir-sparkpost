defmodule SparkPost.Content.TemplateRef do
  @moduledoc """
  Reference to a named SparkPost template.

  Designed for use in `%SparkPost.Transmission{content: ...}`.

  ## Fields
   - template_id: stored template identifier
   - use_draft_template: use the draft version of this template?
  """

  defstruct template_id: :required, use_draft_template: nil
end
