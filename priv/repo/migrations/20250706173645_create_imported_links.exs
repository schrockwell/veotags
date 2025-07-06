defmodule Veotags.Repo.Migrations.CreateImportedLinks do
  use Ecto.Migration

  def change do
    create table(:imported_links) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:imported_links, [:name])
  end
end
