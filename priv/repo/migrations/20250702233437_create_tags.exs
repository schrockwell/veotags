defmodule Veotags.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :address, :string, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :radius, :integer, null: false
      add :email, :string
      add :comment, :text
      add :approved_at, :utc_datetime
      add :photo, :string, null: false
      add :reporter, :string
      add :source_url, :string

      timestamps(type: :utc_datetime)
    end

    create index(:tags, :latitude)
    create index(:tags, :longitude)
    create index(:tags, :email)
    create index(:tags, :approved_at)
    create index(:tags, :reporter)
  end
end
