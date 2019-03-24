# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_view_examples,
  ecto_repos: [LiveViewExamples.Repo]

# Configures the endpoint
config :live_view_examples, LiveViewExamplesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bkmw1+1w48sY50qjauaHYtL6wfS8R/i609VhogFTZzXl5SGv/ybANs3QpQIzuex6",
  render_errors: [view: LiveViewExamplesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveViewExamples.PubSub, adapter: Phoenix.PubSub.PG2],
  check_origin: false,
  live_view: [signing_salt: "salt beef"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix, template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
