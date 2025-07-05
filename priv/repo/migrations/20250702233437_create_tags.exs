defmodule Veotags.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :address, :text, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :radius, :integer, null: false
      add :email, :text
      add :comment, :text
      add :approved_at, :utc_datetime
      add :photo, :text, null: false
      add :reporter, :text
      add :source_url, :text
      add :photo_url, :text
      add :photo_url_expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:tags, :latitude)
    create index(:tags, :longitude)
    create index(:tags, :email)
    create index(:tags, :approved_at)
    create index(:tags, :reporter)
  end
end
