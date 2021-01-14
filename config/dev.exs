use Mix.Config

config :exmc, ExmcWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :exmc, :mc_server,
  listener_opts: [
    transport: :ranch_tcp,
    transport_opts: [
      socket_opts: [
        port: 2775
      ],
      num_acceptors: 100,
      max_connections: 3000
    ]
  ],
  mc_opts: [
    timer_resolution: 1000,
    session_init_limit: :timer.seconds(120),
    enquire_link_limit: :timer.seconds(120),
    enquire_link_resp_limit: :timer.seconds(120),
    inactivity_limit: :infinity,
    response_limit: :timer.minutes(1)
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
