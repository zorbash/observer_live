# ObserverLive

This is a port of [observer_cli][observer_cli] using phoenix and [LiveView][liveview].

:warning: It's still a work in progress and has not been tested in production.

Demo: [Try it][demo]

Video:

![video](https://i.imgur.com/VVhUvMg.gif)

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
