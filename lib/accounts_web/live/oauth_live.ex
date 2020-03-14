defmodule AccountsWeb.OauthLive do
  @moduledoc """
  Socket handling for browser updating on the login page.
  """

  use Phoenix.LiveView

  alias Ecto.Changeset
  alias Accounts.User

  @default_state [
    template: "login.html",
    token: nil,
    error: nil
  ]

  def render(assigns) do
    Phoenix.View.render(AccountsWeb.OauthView, assigns.template, assigns)
  end

  defp set(socket, params \\ []) do
    assigns = Keyword.merge(@default_state, params)
    assign(socket, assigns)
  end

  defp wait(socket, user) do
    with {:ok, token} <- User.login(user.email) do
      AccountsWeb.Endpoint.subscribe("token:" <> to_string(token.id))
      {:noreply, set(socket, template: "logging_in.html", token: token)}
    end
  end

  defp register(socket, email) do
    with {:ok, token} <- User.create(email) do
      AccountsWeb.Endpoint.subscribe("token:" <> to_string(token.id))
      {:noreply, set(socket, template: "registering.html", token: token)}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, set(socket)}
  end

  def handle_event("login", %{"email" => email}, socket) do
    case User.get(email) do
      nil -> register(socket, email)
      user -> wait(socket, user)
    end
  end

  def handle_info(%{event: "used", payload: %{token: token}}, socket) do
    {:noreply, set(socket, template: "complete.html", token: token)}
  end
end
