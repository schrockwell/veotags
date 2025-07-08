defmodule Veotags.Repo.Migrations.MakePhotoNullable do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      modify :photo, :text, null: true
    end
  end
end
