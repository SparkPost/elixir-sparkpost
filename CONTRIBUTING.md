# Contributing to elixir-sparkpost

Transparency is one of our core values, and we encourage developers to contribute and become part of the SparkPost developer community.

The following is a set of guidelines for contributing to elixir-sparkpost,
which is hosted in the [SparkPost Organization](https://github.com/sparkpost) on GitHub.
These are just guidelines, not rules, use your best judgment and feel free to
propose changes to this document in a pull request.

## Submitting Issues

* Before logging an issue, please [search existing issues](https://github.com/SparkPost/elixir-sparkpost/issues?q=is%3Aissue+is%3Aopen) first.

* You can create an issues [here](https://github.com/SparkPost/elixir-sparkpost/issues/new).  Please include the library version number and as much detail as possible in your report.

You can grab the library version number like this: `mix deps | grep sparkpost`

## Local Development

1. Fork this repo
1. Clone your fork
1. Write some code!
1. Retrieve dependencies: `mix deps.get`
1. To run the test suite: `mix test`
1. To check test code coverage: `mix coveralls`
1. To check coding standards: `mix credo`
1. To generate reference docs: `mix docs`
1. Please follow the pull request submission steps in the next section

## Contribution Steps

- We follow this community [Elixir Style Guide](https://github.com/niftyn8/elixir_style_guide).
- We strive for 100% test coverage.
- We include @moduledoc and @doc content (almost) everywhere.

To contribute to elixir-sparkpost:

1. Create a new branch named after the issue you’ll be fixing (include the issue number as the branch name, example: Issue in GH is #8 then the branch name should be ISSUE-8))
1. Write corresponding tests and code (only what is needed to satisfy the issue and tests please)
    * Include your tests in the 'test' directory in an appropriate test file
    * Write code to satisfy the tests
1. Ensure automated tests (`mix test`) pass
1. Submit a new Pull Request applying your feature/fix branch to the `master` branch

### Releasing

Check out these general [docs on publishing packages](https://hex.pm/docs/publish) to Hex.

To publish a new release:

1. Update `package` metadata in mix.exs:
  * bump the version number
  * add new files you want to distribute

```elixir
defp package do
  [
		version: "0.1.0", # <-- bump this
	  files: [
      "lib", "mix.exs", "README.md", "CONTRIBUTING.md" # <-- add new files for distro here
    ], 
  ]
end
```

3. When you're ready, publish to Hex: `mix hex.publish` 

