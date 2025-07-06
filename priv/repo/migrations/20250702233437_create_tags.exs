defmodule Veotags.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :latitude, :float
      add :longitude, :float
      add :email, :text
      add :comment, :text
      add :approved_at, :utc_datetime
      add :reporter, :text
      add :photo, :text, null: false
      add :source_url, :text
      add :photo_url, :text
      add :photo_url_expires_at, :utc_datetime
      add :submitted_at, :utc_datetime
      add :accuracy, :string, default: "unknown"
      add :number, :integer
      add :reddit_name, :string

      timestamps(type: :utc_datetime)
    end

    create index(:tags, :latitude)
    create index(:tags, :longitude)
    create index(:tags, :email)
    create index(:tags, :submitted_at)
    create index(:tags, :approved_at)
    create index(:tags, :reporter)
    create index(:tags, :accuracy)
    create unique_index(:tags, :number)
    create unique_index(:tags, :reddit_name)
  end
end
