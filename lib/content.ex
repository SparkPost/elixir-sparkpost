defmodule Sparkpost.Content do
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

  def to_content(%{email_rfc822: email_rfc822}) do
    %Sparkpost.Content.Raw{email_rfc822: email_rfc822}
  end

  def to_content(%{template_id: template_id, use_draft_template: draft_flag}) do
    %Sparkpost.Content.TemplateRef{template_id: template_id, use_draft_template: draft_flag}
  end

  def to_content(content) when is_map(content) do
    %{ struct(Sparkpost.Content.Inline, content) |
      from: Sparkpost.Address.to_address(content.from)}
  end
end
