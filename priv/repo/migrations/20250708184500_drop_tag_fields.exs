defmodule Veotags.Repo.Migrations.DropTagFields do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      remove :number
      remove :photo_url
      remove :photo_url_expires_at
      remove :reddit_name
    end
  end
end
