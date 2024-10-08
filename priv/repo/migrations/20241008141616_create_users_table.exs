defmodule CameraApi.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :ended_at, :utc_datetime
      add :external_id, :binary_id
      add :email, :string

      timestamps()
    end

    create index(:users, [:name])
  end
end
