defmodule SparkPost.ContentTest do
  use ExUnit.Case

  alias SparkPost.Content

  def md5(blob) do
    :crypto.hash(:md5, blob)
  end

  test "Correctly encodes attachment data" do
    filename = "sparky.png"
    mime_type = "image/png"
    content = File.read!("test/data/" <> filename)
    attachment = Content.to_attachment(filename, mime_type, content)
    assert md5(content) == md5(Base.decode64!(attachment.data))
  end
end
