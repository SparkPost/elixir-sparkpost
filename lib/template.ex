defmodule Sparkpost.Template do
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

  defmodule Ref do
    defstruct template_id: :required, use_draft_template: nil
  end
end
