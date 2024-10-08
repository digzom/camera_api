defmodule CameraApi.Repo.Migrations.CreateCamerasTable do
  use Ecto.Migration

  def change do
    create table(:cameras) do
      add :brand, :string, null: false
      add :name, :string, null: false
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cameras, [:user_id])
    create index(:cameras, [:brand])
    create index(:cameras, [:name])
  end
end
