# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_tableaux,
  ecto_repos: [LiveTableaux.Repo]

# Configures the endpoint
config :live_tableaux, LiveTableauxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SbVktRiu8Wd/gbzTR5Xi0x59J547d50TUO4bSKccMsNqwXIg3bUe5MSYjFvELwbC",
  render_errors: [view: LiveTableauxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveTableaux.PubSub,
  live_view: [signing_salt: "AM/8pFVt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
