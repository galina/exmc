# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exmc,
  ecto_repos: [Exmc.Repo]

# Configures the endpoint
config :exmc, ExmcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uQ/DS0xAn3t3IzaJ0uryJzcHM5Fr2twLaY2ejaDOlH86CVidLucsVje/9RNfUOP7",
  render_errors: [view: ExmcWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Exmc.PubSub,
  live_view: [signing_salt: "9t+fDEcf"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
