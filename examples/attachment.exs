from = "soporte@eleventa.com"
to = "dev.sam23d@gmail.com"

SparkPost.Transmission.send(
  %SparkPost.Transmission{
    recipients: [ %SparkPost.Recipient{ address: %SparkPost.Address{ email: to } } ],
    content: %SparkPost.Content.Inline{
      from: from,
      subject: "Now with attachments!",
      text: "There is an attachment with this message"
    }
  }
)
