defmodule SparkPost.Transmission do
  @moduledoc """
  The SparkPost Transmission API endpoint for sending email.

  Use `SparkPost.Transmission.send/1` to send messages,
  `SparkPost.Transmission.list/1` to list previous sends and
  `SparkPost.Transmission.get/1` to retrieve details on a given transmission.

  Check out the documentation for each function
  or use the [SparkPost API reference](https://www.sparkPost.com/api#/reference/transmissions)
  for details.

  ## Request Fields

  Used in calls to `SparkPost.Transmission.send/1`.
   - campaign_id
   - return_path
   - metadata
   - substitution_data
   - recipients
   - content

  Returned by `SparkPost.Transmission.list/1`.
   - id
   - campaign_id
   - description
   - content

  Returned by `SparkPost.Transmission.get/1`.
   - id
   - description
   - state
   - campaign_id
   - content
   - return_path
   - rcpt_list_chunk_size
   - rcpt_list_total_chunks
   - num_rcpts
   - num_generated
   - num_failed_gen
   - generation_start_time
   - generation_end_time
   - substitution_data
   - metadata
   - options
  """

  defstruct options: %SparkPost.Transmission.Options{},
            campaign_id: nil,
            return_path: nil,
            metadata: nil,
            substitution_data: nil,
            recipients: :required,
            content: :required,
            # System generated fields from this point on
            id: nil,
            description: nil,
            state: nil,
            rcpt_list_chunk_size: nil,
            rcp_list_total_chunks: nil,
            num_rcpts: nil,
            num_generated: nil,
            num_failed_gen: nil,
            generation_start_time: nil,
            generation_end_time: nil

  alias SparkPost.{
    Content,
    Endpoint,
    Recipient,
    Transmission
  }

  @doc """
  Create a new transmission and send some email.

  ## Parameters
  - %SparkPost.Transmission{} consisting of:
    - recipients: ["email@address", %SparkPost.Recipient{}, ...] or %SparkPost.Recipient.ListRef{}
    - content: %SparkPost.Content.Inline{}, %SparkPost.Content.Raw{} or %SparkPost.Content.TemplateRef{}
    - options: %SparkPost.Transmission.Options{}
    - campaign_id: campaign identifier (string)
    - return_path: envelope FROM address, available in Enterprise only (email address string)
    - metadata: transmission-level metadata k/v pairs (keyword)
    - substitution_data: transmission-level substitution_data k/v pairs (keyword)

  ## Examples

  ### Send a message to a single recipient with inline text and HTML content

  ```
  SparkPost.Transmission.send(%SparkPost.Transmission{
    recipients: ["to@you.com"],
    content: %SparkPost.Content.Inline{
      from: "from@me.com",
      subject: "A subject",
      text: "Text body",
      html: "<b>HTML</b> body"
    }
  })
  ```

  #=>

  ```
  %SparkPost.Transmission.Response{
    id: "102258889940193104",
    total_accepted_recipients: 1,
    total_rejected_recipients: 0
  }
  ```

  ### Send a message to 2 recipients using a stored message template

  SparkPost.Transmission.send(%SparkPost.Transmission{
    recipients: ["to@you.com", "to@youtoo.com"],
    content: %SparkPost.Content.TemplateRef{template_id: "test-template-1"}
  })

  #=>

  %SparkPost.Transmission.Response{
    id: "102258889940193105",
    total_accepted_recipients: 2,
    total_rejected_recipients: 0
  }

  ### Send a message with an attachment

  SparkPost.Transmission.send(%SparkPost.Transmission{
    recipients: ["to@you.com"],
    content: %SparkPost.Content.Inline{
      subject: "Now with attachments!",
      text: "There is an attachment with this message",
      attachments: [
        SparkPost.Content.to_attachment("cat.jpg", "image/jpeg", File.read!("cat.jpg"))
      ]
    }
  })

  #=>

  %SparkPost.Transmission.Response{
    id: "102258889940193106",
    total_accepted_recipients: 1,
    total_rejected_recipients: 0
  }
  """
  def send(%__MODULE__{} = body) do
    body = %{
      body
      | recipients: Recipient.to_recipient_list(body.recipients),
        content: Content.to_content(body.content)
    }

    response = Endpoint.request(:post, "transmissions", body)
    Endpoint.marshal_response(response, Transmission.Response)
  end

  @doc """
  Retrieve the details of an existing transmission.

  ## Parameters
   - transmission ID: identifier of the transmission to retrieve

  ## Example: Fetch a transmission

  SparkPost.Transmission.get("102258889940193105")

  #=>

  %SparkPost.Transmission{
    campaign_id: "",
    content: %{template_id: "inline", template_version: 0, use_draft_template: false},
    description: "",
    generation_end_time: "2016-01-14T12:52:05+00:00",
    generation_start_time: "2016-01-14T12:52:05+00:00",
    id: "48215348926834924",
    metadata: "",
    num_failed_gen: 0,
    num_generated: 2,
    num_rcpts: 2,
    options: %{click_tracking: true, conversion_tracking: "", open_tracking: true},
    rcp_list_total_chunks: nil,
    rcpt_list_chunk_size: 100,
    recipients: :required,
    return_path: nil,
    state: "Success",
    substitution_data: ""
  }
  """

  def get(transid) do
    response = Endpoint.request(:get, "transmissions/" <> transid)
    Endpoint.marshal_response(response, __MODULE__, :transmission)
  end

  @doc """
  List all multi-recipient transmissions, possibly filtered by campaign_id and/or content.

  ## Parameters
  - query filters to narrow the list (keyword)
    - campaign_id
    - template_id

  ## Example: List all multi-recipient transmissions:

  SparkPost.Transmission.list()

  #=>

  [
    %SparkPost.Transmission{
      campaign_id: "",
      content: %{template_id: "inline"},
      description: "",
      generation_end_time: nil,
      generation_start_time: nil,
      id: "102258558346809186",
      metadata: nil,
      num_failed_gen: nil,
      num_generated: nil,
      num_rcpts: nil,
      options: :required,
      rcp_list_total_chunks: nil,
      rcpt_list_chunk_size: nil,
      recipients: :required,
      return_path: nil,
      state: "Success",
      substitution_data: nil
    },
    %SparkPost.Transmission{
      campaign_id: "",
      content: %{template_id: "inline"},
      description: "",
      generation_end_time: nil,
      generation_start_time: nil,
      id: "48215348926834924",
      metadata: nil,
      num_failed_gen: nil,
      num_generated: nil,
      num_rcpts: nil,
      options: :required,
      rcp_list_total_chunks: nil,
      rcpt_list_chunk_size: nil,
      recipients: :required,
      return_path: nil,
      state: "Success",
      substitution_data: nil
    }
  ]
  """
  def list(filters \\ []) do
    response = Endpoint.request(:get, "transmissions", %{}, %{}, params: filters)

    case response do
      %Endpoint.Response{} ->
        Enum.map(response.results, fn trans -> struct(__MODULE__, trans) end)

      _ ->
        response
    end
  end
end
