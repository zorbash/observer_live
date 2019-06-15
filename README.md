# ObserverLive

This is a port of [observer_cli][observer_cli] using phoenix and [LiveView][liveview].

:warning: It's still a work in progress and has not been tested in production.

Blog post: [observer_live][observer_live]

Demo: [Try it][demo]

Video:

![video](https://i.imgur.com/VVhUvMg.gif)

For other LiveView examples and demos see [here](https://tefter.io/zorbash/lists/phoenix-liveview-examples).

## Roadmap

This project may have started as a demo for the capabilities of
LiveView, but I'm keen to port the rest of observer_cli's ports. Any
help is welcome!

Remaining work:

<details><summary><strong>System - Cache Hit Info</strong></summary>
<img src="https://i.imgur.com/U5wa36c.png" alt="cache hit info"/>

See: <a href="https://github.com/zhongwencool/observer_cli/blob/1.5.0/src/observer_cli_system.erl#L303">source</a>
</details>

<details><summary><strong>ETS</strong></summary>
<img src="https://i.imgur.com/xdBuMC9.png" alt="ets"/>

See: <a href="https://github.com/zhongwencool/observer_cli/blob/1.5.0/src/observer_cli_ets.erl">source</a>
</details>

<details><summary><strong>Mnesia</strong></summary>
<img src="https://i.imgur.com/rAcsVhW.png" alt="mnesia"/>

See: <a href="https://github.com/zhongwencool/observer_cli/blob/1.5.0/src/observer_cli.app.src">source</a>
</details>

<details><summary><strong>App</strong></summary>
<img src="https://i.imgur.com/rp5C9ty.png" alt="app"/>

See: <a href="https://github.com/zhongwencool/observer_cli/blob/1.5.0/src/observer_cli_mnesia.erl">source</a>
</details>

If you're interested to help, submit a PR. For questions find me on elixir-lang.slack.com

## Development

To run it locally:

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Install Node.js dependencies with `cd assets && npm install`
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## License

Copyright (c) 2019 Dimitris Zorbas, MIT License.

[observer_cli]: https://github.com/zhongwencool/observer_cli
[phoenix]: https://github.com/phoenixframework/phoenix
[demo]: https://liveview.zorbash.com
[liveview]: https://github.com/phoenixframework/phoenix_live_view
[observer_live]: https://zorbash.com/post/observer-live/
