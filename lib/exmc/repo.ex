defmodule Exmc.Repo do
  use Ecto.Repo,
    otp_app: :exmc,
    adapter: Ecto.Adapters.Postgres
end
