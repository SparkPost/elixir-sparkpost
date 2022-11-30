## Change Log

# 0.7 (2022-11-30)

- [FEATURE] Add `SparkPost.Template.list/1`
- Upgrade elixir to 1.14.1
- Upgrade dialyxir to ~>1.2
- Upgrade poison to ~>5.0
- Upgrade excoveralls to ~>0.15
- Upgrade credo to ~>1.6
- Upgrade ex_doc to ~>0.29

# Older releases
## v0.6 (2020-12-14) [unreleased]

- [FEATURE] Add `SparkPost.Event.search_message_events/1`
- [INTERNAL] Add Github Actions Workflow for CI
- [INTERNAL] Add elixir formatter
- [INTERNAL] Add credo
- [INTERNAL] Add dialyzer
- Update mix elixir version 1.2 -> 1.10.4
- Update htttpoison 1.0 -> 1.7
- Update poison 2.0 or 3.0 -> 4.0
- Update mock 0.2 -> 0.3.5
- Update excoveralls 0.5.7 -> 0.13
- Update earmark 1.0.3 -> 1.4
- Update ex_doc 0.14.3 -> 0.20
- [FEATURE] Add `SparkPost.Template.create/1`
- [FEATURE] Add `SparkPost.Template.update/2`
- [FEATURE] Add `SparkPost.Template.delete/1`

## v0.5.2 (2018-05-14)
- Bumped httpoison dep to ~1.0 (thanks @jasongoodwin)

## v0.5.1 (2017/05/22)
- Poison dependency further relaxed to ~> 2.0 or ~> 3.0 to allow for Phoenix
- Removed unnecessary ibrowse mention from README

## v0.5.0 (2017/04/13)
- This release brought to you by the tireless @asgoel
- Core suppression list support
- Poison dependency relaxed to ~> 3.0
- Fixed an issue caused by a double slash in API URL

## v0.4.0 (2017/02/28)
- Template preview support contributed by @asgoel - Thanks!

## v0.3.0 (2017/02/03)
- Made Transmission.options.return_path optional. It's only useful for Enterprise customers.
- Added a `:http_recv_timeout` config param (thanks davidefedrigo)
- Bumped default connection timeout to 30 secs

## v0.2.1 (2016/11/03)
- Added support for `start_time`, `ip_pool` and `inline_css` transmission options
- Updated deps to latest versions

## v0.2.0 (2016/08/25)
- HTTPoison conversion contributed by DavidAntaramian

### v0.1.0 (2016/01/21)
- First release

