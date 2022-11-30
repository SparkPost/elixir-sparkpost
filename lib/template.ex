defmodule SparkPost.Template do
  @moduledoc """
  The SparkPost Template API for working with templates. Use `SparkPost.Template.preview/2` to
  preview a template.

  Check out the documentation for each function
  or use the [SparkPost API reference](https://developers.sparkpost.com/api/templates.html) for details.

  ## Struct Fields

   - id: Template identifier, auto-generated if not provided upon create.
   - name: Editable template display name, auto-generated if not provided. At minimum, `:name` or `:id` is required, but not both
   - content: Content that will be used to construct a message. Can be a `%SparkPost.Content.Inline` or a `%SparkPost.Content.Raw{}`
   - published: Boolean indicating the published/draft state of the template. Defaults to false
   - description: Detailed description of the template
   - options: A `%SparkPost.Transmission.Options{}` struzct, but only `:open_tracking`, `:click_tracking` and `:transactional` are accepted when working with a template.
   - shared_with_subaccounts: boolean indicating if the template is accessible to subaccounts. Defaults to false.
   - has_draft: Read-only. Indicates if template has a draft version.
   - has_published: Read-only. Indicates if template has a published version.
  """

  alias SparkPost.Content
  alias SparkPost.Endpoint
  alias SparkPost.Transmission

  defstruct id: nil,
            name: nil,
            content: %Content.Inline{},
            published: false,
            description: nil,
            options: %Transmission.Options{},
            shared_with_subaccounts: false,
            has_draft: nil,
            has_published: nil

  @type t :: %__MODULE__{}

  @doc """
  Lists email templates

  https://developers.sparkpost.com/api/templates/#templates-get-list-all-templates


  """
  @spec list(%{
          optional(:draft) => boolean,
          optional(:shared_with_subaccounts) => boolean
        }) :: list(t)
  def list(%{} = params \\ %{}) do
    query =
      params
      |> Map.take([:draft, :shared_with_subaccounts])
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Keyword.new()

    :get
    |> Endpoint.request("templates", %{}, %{}, params: query)
    |> Endpoint.marshal_response(__MODULE__)
  end

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

  Response is a `%SparkPost.Content.Inline{}` consisting of
    - from
      - email
      - name
    - subject
    - reply_to
    - text
    - html
    - headers
  """
  def preview(%SparkPost.Content.TemplateRef{} = template, substitution_data) do
    qs =
      if is_nil(template.use_draft_template) do
        ""
      else
        "?draft=#{template.use_draft_template}"
      end

    body = %{substitution_data: substitution_data}

    :post
    |> Endpoint.request("templates/#{template.template_id}/preview#{qs}", body)
    |> Endpoint.marshal_response(SparkPost.Content.Inline)
    |> Content.Inline.convert_from_field()
  end

  @doc """
  Create a SparkPost Template

  ## Parameters

  - `%SparkPost.Template{}`

  ## Response

  - `%SparkPost.Template.Response{}`
  """
  def create(%__MODULE__{} = template) do
    :post
    |> Endpoint.request("templates", template)
    |> Endpoint.marshal_response(SparkPost.Template.Response)
  end

  @doc """
  Update a SparkPost Template

  ## Parameters

  - `%SparkPost.Template{}` containing a valid `:id` as well as the updated content
  - optional keyword list as a second argument, supporting the fields
    - `:update_published` - defaults to false, specifies if the published version of the template should be directly updated, instead of storing the update as a draft

  ## Note on `:update_published` option, vs `:published` struct field

  Setting `published: true` on the struct itself performs the act of publishing a draft template. If the field is set to
  `true`, the `:update_published` option is ingored completely.
  """
  def update(
        %__MODULE__{id: template_id, published: published} = template,
        options \\ [update_published: false]
      ) do
    qs =
      if published != true && Keyword.get(options, :update_published, false) == true do
        "?update_published=true"
      else
        ""
      end

    :put
    |> Endpoint.request("templates/#{template_id}#{qs}", template)
    |> Endpoint.marshal_response(SparkPost.Template.Response)
  end

  @doc """
  Delete a SparkPost Template

  ## Parameters

  - a valid template id

  ## Response

  - `{:ok, %SparkPost.Endpoint.Response{}}` if successful
  - `{:error, %SparkPost.Endpoint.Error{}}` if failure
  """
  def delete(template_id) do
    case Endpoint.request(:delete, "templates/#{template_id}") do
      %SparkPost.Endpoint.Response{status_code: 200} = response -> {:ok, response}
      other -> {:error, other}
    end
  end
end
