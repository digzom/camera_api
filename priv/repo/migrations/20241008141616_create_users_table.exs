defmodule CameraApi.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :terminated_at, :utc_datetime

      timestamps()
    end

    create index(:users, [:name])
  end
end
