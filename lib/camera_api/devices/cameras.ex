defmodule CameraApi.Devices.Camera do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cameras" do
    field :external_id, :binary_id
    field :brand, :string
    field :name, :string
    field :active, :boolean, default: true
    belongs_to :user, CameraApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:brand, :name, :active, :user_id])
    |> validate_required([:brand, :name, :active, :user_id])
    |> validate_inclusion(:brand, ["Intelbras", "Hikvision", "Giga", "Vivotek"])
    |> put_change(:external_id, Ecto.UUID.generate())
  end
end
