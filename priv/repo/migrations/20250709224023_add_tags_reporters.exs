defmodule Veotags.Repo.Migrations.AddTagsReporters do
  use Ecto.Migration

  def up do
    alter table(:tags) do
      add :reporters, :map, default: fragment("'[]'::jsonb"), null: false
    end

    flush()

    execute(
      "UPDATE tags SET reporters = jsonb_build_array(jsonb_build_object('name', reporter, 'email', email)) WHERE reporter IS NOT NULL OR email IS NOT NULL;"
    )

    alter table(:tags) do
      remove :reporter
      remove :email
    end
  end
end
