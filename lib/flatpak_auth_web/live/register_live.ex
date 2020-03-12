defmodule FlatpakAuthWeb.RegisterLive do
  use Phoenix.LiveView

  alias Ecto.Changeset
  alias FlatpakAuth.User

  def render(assigns) do
    Phoenix.View.render(FlatpakAuthWeb.UserView, "register.html", assigns)
  end

  defp set(socket, params \\ []) do
    assigns = Keyword.merge([done: false, error: nil, waiting: false], params)
    assign(socket, assigns)
  end

  defp wait_for_validation(socket, user_id) do
    FlatpakAuthWeb.Endpoint.subscribe("user:" <> to_string(user_id))
    {:noreply, set(socket, waiting: true)}
  end

  def mount(_params, _session, socket) do
    {:ok, set(socket)}
  end

  def handle_event("register", %{"email" => email}, socket) do
    with {:ok, user} <- User.create(email) do
      wait_for_validation(socket, user.id)
    else
      {:error, %Changeset{} = changeset} ->
        error =
          changeset.errors
          |> Enum.map(fn {key, {value, _}} -> "#{key} #{value}" end)
          |> Enum.join(", ")

        {:noreply, set(socket, error: error)}

      {:error, msg} ->
        {:noreply, set(socket, error: msg)}

      _ ->
        {:noreply, set(socket, error: "Unable to create user")}
    end
  end

  def handle_info(%{event: "validated"}, socket) do
    {:noreply, set(socket, done: true)}

    # TODO: Redirect with registered headers here!
  end
end