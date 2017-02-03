from = "elixir@sparkpostbox.com"
to = "ewan.dennis@sparkpost.com"
filename = "test/data/sparky.png"

SparkPost.Transmission.send(
  %SparkPost.Transmission{
    recipients: [to],
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
