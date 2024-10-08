defmodule CameraApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :external_id, :binary_id
    field :name, :string
    field :ended_at, :utc_datetime
    has_many :cameras, CameraApi.Devices.Camera

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :ended_at])
    |> validate_required([:name])
    |> put_change(:external_id, Ecto.UUID.generate())
  end
end

