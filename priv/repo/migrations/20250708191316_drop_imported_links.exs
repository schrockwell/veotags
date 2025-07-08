defmodule Veotags.Repo.Migrations.DropImportedLinks do
  use Ecto.Migration

  def change do
    drop table(:imported_links)
  end
end
