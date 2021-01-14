defmodule ExmcWeb.Router do
  use ExmcWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExmcWeb do
    pipe_through :api

    post "/message", MessageController, :send_message
  end
end
