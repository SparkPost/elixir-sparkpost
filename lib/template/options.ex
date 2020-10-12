defmodule SparkPost.Template.Options do
  @moduledoc """
  Template options.

  Designed for use in `%SparkPost.Content.Template{options: ...}`

  ## Fields
   - open_tracking: enable 'email open' tracking?
   - click_tracking: enable 'link click' tracking?
   - transactional: is this a transactional message?
  """

  defstruct open_tracking: true,
            click_tracking: true,
            transactional: nil
end
