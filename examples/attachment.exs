from = "me@here.com"
to = "you@there.com"
filename = "test/data/sparky.png"

SparkPost.Transmission.create(
  %SparkPost.Transmission{
    recipients: [to],
    return_path: from,
    content: %SparkPost.Content.Inline{
      from: from,
      subject: "Now with attachments!",
      text: "There is an attachment with this message",
      attachments: [
        SparkPost.Content.to_attachment(
          Path.basename(filename), "image/jpeg", File.read!(filename)
        )
      ]
    }
  }
)
