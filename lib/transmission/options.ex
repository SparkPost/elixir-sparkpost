defmodule SparkPost.Transmission.Options do
  @moduledoc """
  Transmission options.

  Designed for use in `%SparkPost.Transmission{options: ...}`

  ## Fields
   - open_tracking: enable 'email open' tracking?
   - click_tracking: enable 'link click' tracking?
   - transactional: is this a transactional message?
   - sandbox: send using the sandbox domain? (sparkpost.com only)
   - skip_suppression: ignore per-customer suppresssion rules? (SparkPost Elite only)
  """

  defstruct start_time: nil,
    open_tracking: true,
    click_tracking: true,
    transactional: nil,
    sandbox: nil,
    skip_suppression: nil
end
