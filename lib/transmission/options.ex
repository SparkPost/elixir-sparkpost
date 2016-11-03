defmodule SparkPost.Transmission.Options do
  @moduledoc """
  Transmission options.

  Designed for use in `%SparkPost.Transmission{options: ...}`

  ## Fields
   - start_time: schedule transmission for a future time
   - open_tracking: enable 'email open' tracking?
   - click_tracking: enable 'link click' tracking?
   - transactional: is this a transactional message?
   - sandbox: send using the sandbox domain? (sparkpost.com only)
   - skip_suppression: ignore per-customer suppresssion rules? (SparkPost Elite only)
   - ip_pool: name of dedicated IP pool to send from
   - inline_css: perform CSS inline on HTML content?
  """

  defstruct start_time: nil,
    open_tracking: true,
    click_tracking: true,
    transactional: nil,
    sandbox: nil,
    skip_suppression: nil,
    ip_pool: nil,
    inline_css: nil
end
