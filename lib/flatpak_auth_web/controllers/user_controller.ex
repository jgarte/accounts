defmodule FlatpakAuthWeb.UserController do
  use FlatpakAuthWeb, :controller

  alias FlatpakAuth.User

  def register(conn, _params) do
    live_render(conn, FlatpakAuthWeb.RegisterLive)
  end

  def validate(conn, %{"key" => key}) do
    case User.validate(key) do
      {:ok, _user} ->
        render(conn, "validated.html")

      {:error, "user not found"} ->
        put_status(conn, :not_found)

      _ ->
        put_status(conn, 500)
    end
  end

  def login(conn, _params) do
    live_render(conn, FlatpakAuthWeb.LoginLive)
  end
end
