from = "ewan@cloudygoo.com"
to = "ewan.dennis@sparkpost.com"
filename = "test/data/sparky.png"

Sparkpost.Transmission.create(
  %Sparkpost.Transmission{
    options: %Sparkpost.Transmission.Options{},
    recipients: Sparkpost.Recipient.to_recipient_list([to]),
    return_path: from,
    content: %Sparkpost.Content.Inline{
      from: from,
      subject: "Now with attachments!",
      text: "There is an attachment with this message",
      attachments: [
        Sparkpost.Content.to_attachment(
          Path.basename(filename), "image/jpeg", File.read!(filename)
        )
      ]
    }
  }
)
