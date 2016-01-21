to = "you@there.com"
from = "Elixir SparkPost <elixir@sparkpostbox.com>"
SparkPost.send(
  to: to,
  from: from,
  subject: "My first Elixir email", 
  text: "This is the boring version of the email body",
  html: "This is the <strong>tasty</strong> <em>rich</em> version of the <a href=\"https://www.sparkpost.com/\">email</a> body."
)
