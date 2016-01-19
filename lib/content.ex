defmodule SparkPost.Content do
  defmodule Inline do
    defstruct from: :required,
      subject: :required,
      text: nil,
      html: nil,
      reply_to: nil,
      headers: nil,
      attachments: nil,
      inline_images: nil
  end

  defmodule Raw do
    defstruct email_rfc822: :required
  end

  defmodule TemplateRef do
    defstruct template_id: :required, use_draft_template: nil
  end

  defmodule Attachment do
    defstruct name: :required, type: :required, data: :required
  end

  def to_attachment(name, type, data) when is_binary(data) do
    %SparkPost.Content.Attachment{
      name: name,
      type: type,
      data: Base.encode64(data)
    }
  end

  def to_content(%{email_rfc822: email_rfc822}) do
    %SparkPost.Content.Raw{email_rfc822: email_rfc822}
  end

  def to_content(%{template_id: template_id, use_draft_template: draft_flag}) do
    %SparkPost.Content.TemplateRef{template_id: template_id, use_draft_template: draft_flag}
  end

  def to_content(content) when is_map(content) do
    %{ struct(SparkPost.Content.Inline, content) |
      from: SparkPost.Address.to_address(content.from)}
  end
end
