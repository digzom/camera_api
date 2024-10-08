defmodule CameraApiWeb.CamerasController do
  use CameraApiWeb, :controller

  alias CameraApi.Account
  alias CameraApiWeb.FallbackController

  action_fallback(FallbackController)

  def index(conn, params) do
    with {:ok, users_with_cameras} <- Account.list_users_with_active_cameras(params) do
      conn
      |> put_status(:ok)
      |> render(:index, users: users_with_cameras)
    end
  end
end
