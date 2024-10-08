defmodule CameraApiWeb.NotificationController do
  use CameraApiWeb, :controller
  alias CameraApi.Account
  alias CameraApi.EmailNotifier

  def create(conn, _params) do
    users = Account.list_users_with_hikvision_cameras()

    results =
      Enum.map(users, fn user ->
        case EmailNotifier.send_notification(user.email, user.name) do
          {:ok, _} -> %{user: user.name, status: "sent"}
          {:error, reason} -> %{user: user.name, status: "failed", reason: reason}
        end
      end)

    conn
    |> put_status(:ok)
    |> json(%{message: "Notifications processed", results: results})
  end
end
