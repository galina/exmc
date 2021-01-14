use Mix.Config

config :exmc, ExmcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uQ/DS0xAn3t3IzaJ0uryJzcHM5Fr2twLaY2ejaDOlH86CVidLucsVje/9RNfUOP7",
  render_errors: [view: ExmcWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Exmc.PubSub,
  live_view: [signing_salt: "9t+fDEcf"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :debug

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
