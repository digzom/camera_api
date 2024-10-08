defmodule CameraApiWeb.CamerasJSON do
  def index(%{users: users}), do: %{data: users}
end
