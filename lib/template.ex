defmodule SparkPost.Template do
  @moduledoc """
  The SparkPost Template API for working with templates. Use `SparkPost.Template.preview/2` to
  preview a template.

  Check out the documentation for each function
  or use the [SparkPost API reference](https://developers.sparkpost.com/api/templates.html) for details.

  Returned by `SparkPost.template.preview/2`.
    - from
      - email
      - name
    - subject
    - reply_to
    - text
    - html
    - headers
  """

  alias SparkPost.Endpoint

  @doc """
  Generate a preview of an existing template.

  ### Parameters
  - %SparkPost.Content.TemplateRef{} consisting of:
    - template_id: The string id of the template to retrieve a preview or.
    - use_draft_template: If true, previews the most recent draft template.
        If false, previews the most recent published template. If nil,
        previews the most recently template version period.
  - substitution_data: k,v map consisting of substituions. See the
      [SparkPost Substitutions Reference](https://developers.sparkpost.com/api/substitutions-reference.html)
      for more details.
  """
  def preview(%SparkPost.Content.TemplateRef{} = template, substitution_data) do
    qs = if is_nil(template.use_draft_template) do
      ""
    else
      "?draft=#{template.use_draft_template}"
    end
    body = %{substitution_data: substitution_data}
    :post
    |> Endpoint.request("templates/#{template.template_id}/preview#{qs}", body)
    |> Endpoint.marshal_response(SparkPost.Content.Inline)
    |> SparkPost.Content.Inline.convert_from_field
  end
end
