defmodule ExmcWeb.MessageController do
  use ExmcWeb, :controller

  require Logger

  def send_message(conn, %{"system_id" => client, "src" => src, "dst" => dst, "text" => text}) do
    Logger.info("client #{client} sends message from #{src} to #{dst}")

    case Exmc.Session.send_message(client, %{src: src, dst: dst, text: text}) do
      {:error, :nosession} ->
        json(conn, %{"error" => "nosession", "result" => "error"})

      :ok ->
        json(conn, %{"result" => "ok"})
    end
  end

  def send_message(conn, _params) do
    json(conn, %{"error" => "invalid_params", "result" => "error"})
  end
end
