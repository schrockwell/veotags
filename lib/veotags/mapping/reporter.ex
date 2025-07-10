defmodule Veotags.Mapping.Reporter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
  end

  @doc false
  def changeset(reporter, attrs) do
    reporter
    |> cast(attrs, [:name, :email])
    |> validate_length(:name, max: 100)
    |> validate_length(:email, max: 1000)
    |> validate_format(:email, ~r/@/)
  end
end
