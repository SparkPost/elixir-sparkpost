defmodule SparkPost.Template.ContentResponse do
  @moduledoc """
  The content portion of a response generated when SparkPost receives a Template object.

  See the [SparkPost Template Documentation](https://developers.sparkpost.com/api/templates.html#header-content-attributes)
  for more details.

  ## Fields
    - html: HTML content for the email's text/html MIME part
    - text: Text content for the email's text/plain MIME part
    - subject: Email subject line
    - from: a %SparkPost.Address{} object
    - reply_to: Email address used to compose the email's "Reply-To" header
    - headers: JSON object container headers other than "Subject", "From", "To" and "Reply-To"
  """

  defstruct html: nil,
    text: nil,
    subject: :required,
    from: :required,
    reply_to: nil,
    headers: nil

  @doc """
  Convert a raw "from" field into a %SparkPost.Address{} object.
  """
  def convert_from_field(%SparkPost.Endpoint.Error{} = response), do: response
  def convert_from_field(%__MODULE__{} = response) do
    %{response | from: SparkPost.Address.to_address(response.from)}
  end
end
