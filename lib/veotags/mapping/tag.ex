defmodule Veotags.Mapping.Tag do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :address, :string
    field :latitude, :float
    field :longitude, :float
    field :radius, :integer, default: 0
    field :email, :string
    field :comment, :string
    field :approved_at, :utc_datetime
    field :photo, Veotags.Photo.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:address, :latitude, :longitude, :radius, :email, :comment])
    |> cast_attachments(attrs, [:photo], allow_paths: true)
    |> validate_required([:address, :latitude, :longitude, :radius])
    |> validate_email()
    |> validate_number(:latitude, greater_than: -90, less_than: 90)
    |> validate_number(:longitude, greater_than: -180, less_than: 180)
    |> validate_number(:radius, greater_than_or_equal_to: 0)
    |> validate_length(:address, max: 255)
    |> validate_length(:email, max: 255)
    |> validate_length(:comment, max: 500)
  end

  def approve_changeset(tag) do
    change(tag, approved_at: DateTime.utc_now())
  end

  defp validate_email(changeset) do
    if get_field(changeset, :email) do
      validate_format(changeset, :email, ~r/@/)
    else
      changeset
    end
  end
end
