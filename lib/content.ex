defmodule SparkPost.Content do
  @moduledoc """
  Various message content representations.

  Designed for use in `%SparkPost.Transmission{content: ...}`.

  See submodules for concrete structs:
   - `SparkPost.Content.Inline`
   - `SparkPost.Content.Raw`
   - `SparkPost.Content.TemplateRef`
  """

  @doc """
  Create a %SparkPost.Content.Attachment from raw fields.

  ## Example
      SparkPost.Content.to_attachment("bob.jpg", "image/jpeg", File.read!("bob.jpg"))
      #=> %SparkPost.Content.Attachment{name: "bob.jpg", type: "image/jpeg", data: "iVBORw0KGgo..."}
  """
  def to_attachment(name, type, data) when is_binary(data) do
    %SparkPost.Content.Attachment{
      name: name,
      type: type,
      data: Base.encode64(data)
    }
  end

  @doc ~S"""
  Convenience conversions:
   - %{email_rc822: ...} -> %SparkPost.Content.Raw
   - %{template_id: ..., use_draft_template: ...} -> %SparkPost.Content.TemplateRef
   - %{...} -> %SparkPost.Content.Inline

  ## Examples
  Raw content:
      SparkPost.Content.to_content(%{email_rfc822: "Content-Type: text/plain\r\nTo: \"{{address.name}}\" <{{address.email}}>\r\n\r\nThis message came from Elixir\r\n"})
      #=> %SparkPost.Content.Raw{email_rfc822: "Content-Type: text/plain\r\nTo: \"{{address.name}}\" <{{address.email}}>\r\n\r\nThis message came from Elixir\r\n"}

  Stored template:
      SparkPost.Content.to_content(%{
        template_id: "template-101",
        use_draft_template: true
      })
      #=> %SparkPost.Content.TemplateRef{template_id: "template-101", use_draft_template: true}

  Inline content:
      Sparkpost.Content.to_content(%{
        from: "me@here.com",
        subject: "Elixir rocks",
        text: "A simple little message"
      })
      #=> %SparkPost.Content.Inline{
        from: "me@here.com",
        subject: "Elixir rocks",
        text: "A simple little message"
      }
  """
  def to_content(%{email_rfc822: email_rfc822}) do
    %SparkPost.Content.Raw{email_rfc822: email_rfc822}
  end

  def to_content(%{template_id: template_id, use_draft_template: draft_flag}) do
    %SparkPost.Content.TemplateRef{template_id: template_id, use_draft_template: draft_flag}
  end

  def to_content(%SparkPost.Content.Inline{} = content) do
    %{ content |
      from: SparkPost.Address.to_address(content.from)}
  end

  def to_content(content) when is_map(content) do
    %{ struct(SparkPost.Content.Inline, content) |
      from: SparkPost.Address.to_address(content.from)}
  end
end
