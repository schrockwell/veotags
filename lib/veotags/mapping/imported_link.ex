defmodule Veotags.Mapping.ImportedLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "imported_links" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(imported_link, attrs) do
    imported_link
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
