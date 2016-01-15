<a href="https://www.sparkpost.com"><img src="https://www.sparkpost.com/sites/default/files/attachments/SparkPost_Logo_2-Color_Gray-Orange_RGB.svg" width="200px"/></a>

[Sign up](https://app.sparkpost.com/sign-up?src=Dev-Website&sfdcid=70160000000pqBb) for a SparkPost account and visit our [Developer Hub](https://developers.sparkpost.com) for even more content.

# SparkPost Elixir Library

[![Travis CI](https://travis-ci.org/SparkPost/elixir-sparkpost.svg?branch=master)](https://travis-ci.org/SparkPost/elixir-sparkpost) [![Coverage Status](https://coveralls.io/repos/SparkPost/elixir-sparkpost/badge.svg?branch=master&service=github)](https://coveralls.io/github/SparkPost/elixir-sparkpost?branch=master)

The official [Elixir](http://elixir-lang.org/) package for using the [SparkPost API](https://www.sparkpost.com/api).

Capabilities include:
 - convenience functions for easy "I just want to send mail" users
 - advanced functions for unleashing all of Sparkpost's capabilities

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add sparkpost to your list of dependencies in `mix.exs`:

        def deps do
          [{:sparkpost, "~> 0.0.1"}]
        end

  2. Ensure sparkpost is started before your application:

        def application do
          [applications: [:sparkpost]]
        end

## Usage

In your config/config.exs file:

```elixir
config :myapp, sparkpost_api_key: "YOUR-API-KEY"
```

### Option: Use Convenience Functions

```elixir
defmodule MyApp.Example do
  use SparkPost.Transmission

  def send_message do
    send to: "you@example.com",
         from: "elixir@sparkpostbox.com",
         subject: "Sending email from Elixir is awesome!",
         text: "Hi there!",
         html: "<p>Hi there!</p>"
  end
end
```

### Option: Use Advanced Functions

```elixir
defmodule MyApp.Example do
  use SparkPost.Transmission
  use SparkPost.Recipient
  use SparkPost.Template

  def send_message do
    Transmission.create(%Transmission.Request{
        options: %Transmission.Options{},
        recipients: [ %Recipient{ address: %Sparkpost.Address{ email: "your@example.com" }} ],
        return_path: "elixir@sparkpostbox.com",
        content: %Template.Inline{
          subject: "Sending email from Elixir is awesome!",
          from: %Sparkpost.Address{ email: "elixir@sparkpostbox.com" },
          text: text,
          html: html
        }
    })
  end
end
```

Start your app and send a message:

```bash
    $ iex -S mix
    iex> MyApp.Example.send_message
    {:ok, ...}
```

### Contribute

### Change Log

[See ChangeLog here](CHANGELOG.md)
