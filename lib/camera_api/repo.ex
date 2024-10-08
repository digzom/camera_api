defmodule CameraApi.Repo do
  use Ecto.Repo,
    otp_app: :camera_api,
    adapter: Ecto.Adapters.Postgres
end
