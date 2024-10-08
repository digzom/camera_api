defmodule CameraApiWeb.CamerasController do
  use CameraApiWeb, :controller
  alias CameraApi.Accounts
  alias CameraApi.FallbackController

  action_fallback(FallbackController)

  def index(conn, params) do
    with {:ok, users_with_cameras} <- Accounts.list_users_with_active_cameras(params) do
      conn
      |> put_status(:ok)
      |> render(:index, users: users_with_cameras)
    end
  end
end
