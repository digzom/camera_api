defmodule CameraApiWeb.CameraView do
  def index(%{users: users}) do
    %{data: Enum.map(users, &user_with_cameras/1)}
  end

  def user_with_cameras(%{user: user}) do
    %{
      id: user.id,
      name: user.name,
      ended_at: user.ended_at,
      cameras: user.cameras
    }
  end
end
