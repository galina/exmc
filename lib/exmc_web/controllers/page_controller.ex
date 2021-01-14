defmodule ExmcWeb.PageController do
  use ExmcWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
