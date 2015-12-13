<a href="https://www.sparkpost.com"><img src="https://www.sparkpost.com/sites/default/files/attachments/SparkPost_Logo_2-Color_Gray-Orange_RGB.svg" width="200px"/></a>

[Sign up](https://app.sparkpost.com/sign-up?src=Dev-Website&sfdcid=70160000000pqBb) for a SparkPost account and visit our [Developer Hub](https://developers.sparkpost.com) for even more content.

# SparkPost Elixir Library

[![Travis CI](https://travis-ci.org/SparkPost/elixir-sparkpost.svg?branch=master)](https://travis-ci.org/SparkPost/elixir-sparkpost) [![Coverage Status](https://coveralls.io/repos/SparkPost/elixir-sparkpost/badge.svg?branch=master&service=github)](https://coveralls.io/github/SparkPost/elixir-sparkpost?branch=master)

The official Go package for using the [SparkPost API](https://www.sparkpost.com/api).

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

```elixir
# In your config/config.exs file
config :myapp, sparkpost_api_key: "YOUR-API-KEY"

# lib/example.ex
defmodule MyApp.Example do
  use SparkPost.Transmissions

  def send_inline do
    send to: ["recipient1@example.com"],
         from: "elixir@sparkpostbox.com",
         subject: "Sending email from Elixir is awesome!",
         text: "Hi there!",
         html: "<p>Hi there!</p>"
  end

  def send_using_template do
    send to: ["recipient1@example.com"],
         template: "my-template"
  end

  def send_using_recipient_list do
    send recipient_list: "my-list",
         template: "my-template"
  end

  def send_with_attachments do
    send to: ["recipient1@example.com"],
         from: "elixir@sparkpostbox.com",
         subject: "Sending email from Elixir is awesome!",
         text: "Hi there!",
         html: "<p>Hi there!</p>",
         attachments: [%{type: "application/pdf",
                         name: "statement.pdf",
                         data: pdf_data}]
  end
end
```

```bash
$ iex -S mix
iex> MyApp.Example.send_message
{:ok, ...}
```

### Contribute

### Change Log

[See ChangeLog here](CHANGELOG.md)
