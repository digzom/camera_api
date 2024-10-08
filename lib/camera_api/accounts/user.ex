defmodule CameraApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :terminated_at, :naive_datetime
    has_many :cameras, CameraApi.Devices.Camera

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :terminated_at])
    |> validate_required([:name])
  end
end
