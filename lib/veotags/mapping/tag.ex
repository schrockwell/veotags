defmodule Veotags.Mapping.Tag do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "tags" do
    field :address, :string
    field :approved_at, :utc_datetime
    field :comment, :string
    field :email, :string
    field :latitude, :float
    field :longitude, :float
    field :photo, Veotags.Photo.Type
    field :radius, :integer, default: 0
    field :reporter, :string
    field :source_url, :string
    field :photo_url, :string
    field :photo_url_expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [
      :address,
      :latitude,
      :longitude,
      :radius,
      :email,
      :comment,
      :reporter,
      :source_url
    ])
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
    change(tag, approved_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  defp validate_email(changeset) do
    if get_field(changeset, :email) do
      validate_format(changeset, :email, ~r/@/)
    else
      changeset
    end
  end

  def approved(query) do
    where(query, [t], not is_nil(t.approved_at))
  end

  def recent(query, limit \\ 10) do
    query
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end
end
