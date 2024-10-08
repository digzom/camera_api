defmodule CameraApiWeb.FallbackController do
  use CameraApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: CameraApiWeb.ErrorJSON)
    |> render(:error, %{changeset: changeset})
  end
end
