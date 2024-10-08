defmodule CameraApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field :name, :string
    field :ended_at, :utc_datetime
    has_many :cameras, CameraApi.Devices.Camera

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :ended_at])
    |> validate_required([:name])
  end
end
