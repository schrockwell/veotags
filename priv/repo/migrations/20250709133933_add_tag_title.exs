defmodule Veotags.Repo.Migrations.AddTagTitle do
  use Ecto.Migration

  def up do
    alter table(:tags) do
      add :title, :text
    end

    flush()

    execute("UPDATE tags SET title = comment")
    execute("UPDATE tags SET comment = NULL")
  end

  def down do
    execute("UPDATE tags SET comment = title WHERE comment IS NULL")

    flush()

    alter table(:tags) do
      remove :title
    end
  end
end
