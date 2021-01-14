defmodule Exmc.Application do
  @moduledoc false

  use Application

  @default_mc_config [
    listener_opts: [
      transport: :ranch_tcp,
      transport_opts: [
        socket_opts: [port: 15000],
        num_acceptors: 100,
        max_connections: 3000
      ]
    ],
    mc_opts: [
      timer_resolution: 1000,
      session_init_limit: :timer.seconds(10),
      enquire_link_limit: :timer.seconds(30),
      enquire_link_resp_limit: :timer.seconds(30),
      inactivity_limit: :infinity,
      response_limit: :timer.minutes(1)
    ]
  ]

  def start(_type, _args) do
    mc_config = Keyword.merge(@default_mc_config, Application.get_env(:exmc, :mc_server, []))

    children = [
      ExmcWeb.Telemetry,
      {Phoenix.PubSub, name: Exmc.PubSub},
      ExmcWeb.Endpoint,
      {Registry, keys: :unique, name: SessionRegistry},
      mc_server_spec(mc_config)
    ]

    opts = [strategy: :one_for_one, name: Exmc.Supervisor, max_restarts: 100_000]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExmcWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp mc_server_spec(config) do
    listener_opts = Keyword.get(config, :listener_opts, [])
    transport_opts = Keyword.get(listener_opts, :transport_opts, [])
    mc_opts = Keyword.get(config, :mc_opts, [])

    {id, start, restart, shutdown, type, modules} =
      :ranch.child_spec(
        make_ref(),
        listener_opts[:transport],
        Map.new(transport_opts),
        SMPPEX.TransportSession,
        {SMPPEX.Session, [{Exmc.Session, config}, mc_opts], :mc}
      )

    %{
      id: id,
      start: start,
      restart: restart,
      shutdown: shutdown,
      type: type,
      modules: modules
    }
  end
end
