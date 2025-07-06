defmodule Veotags.Mapping.Tag do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @accuracy_options [
    {"Exact", "exact"},
    {"Approximate", "approximate"},
    {"Unknown", "unknown"}
  ]

  schema "tags" do
    field :photo, Veotags.Photo.Type
    field :photo_url, :string
    field :photo_url_expires_at, :utc_datetime
    field :latitude, :float
    field :longitude, :float
    field :comment, :string
    field :email, :string
    field :reporter, :string
    field :source_url, :string
    field :submitted_at, :utc_datetime
    field :approved_at, :utc_datetime
    field :accuracy, :string, default: "approximate"
    field :number, :integer

    timestamps(type: :utc_datetime)
  end

  def accuracy_options, do: @accuracy_options

  def mappable?(%__MODULE__{latitude: nil, longitude: nil}), do: false
  def mappable?(_tag), do: true

  ### CHANGESETS  ***

  def initial_photo_changeset(tag, attrs) do
    tag
    |> cast(attrs, [:latitude, :longitude])
    |> cast_attachments(attrs, [:photo], allow_paths: true)
    |> validate_required([:photo])
    |> update_accuracy()
  end

  defp update_accuracy(changeset) do
    if get_field(changeset, :latitude) != nil && get_field(changeset, :longitude) != nil do
      change(changeset, accuracy: "exact")
    else
      changeset
    end
  end

  def submit_changeset(tag, attrs) do
    tag
    |> cast(attrs, [
      :latitude,
      :longitude,
      :accuracy,
      :email,
      :comment,
      :reporter,
      :source_url
    ])
    |> change(submitted_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> cast_attachments(attrs, [:photo], allow_paths: true)
    |> validate_required([:photo])
    |> validate_location()
    |> validate_email()
    |> validate_length(:email, max: 1000)
    |> validate_length(:comment, max: 1000)
  end

  def approve_changeset(tag, number) do
    change(tag,
      approved_at: DateTime.utc_now() |> DateTime.truncate(:second),
      number: tag.number || number
    )
  end

  def delist_changeset(tag) do
    change(tag, approved_at: nil)
  end

  ### VALIDATIONS ***

  defp validate_location(changeset) do
    changeset =
      validate_inclusion(changeset, :accuracy, Enum.map(@accuracy_options, fn {_, v} -> v end))

    if get_field(changeset, :accuracy) == "unknown" do
      changeset
      |> put_change(:latitude, nil)
      |> put_change(:longitude, nil)
    else
      changeset
      |> validate_required([:latitude, :longitude])
      |> validate_number(:latitude, greater_than: -90, less_than: 90)
      |> validate_number(:longitude, greater_than: -180, less_than: 180)
    end
  end

  defp validate_email(changeset) do
    if get_field(changeset, :email) do
      validate_format(changeset, :email, ~r/@/)
    else
      changeset
    end
  end

  ### QUERIES ***

  def approved(query) do
    where(query, [t], not is_nil(t.approved_at))
  end

  def submitted(query) do
    where(query, [t], not is_nil(t.submitted_at) and is_nil(t.approved_at))
  end

  def abandoned(query) do
    cutoff = DateTime.shift(DateTime.utc_now(), day: -1)
    where(query, [t], is_nil(t.submitted_at) and t.inserted_at < ^cutoff)
  end

  def with_coordinates(query) do
    where(query, [t], not is_nil(t.latitude) and not is_nil(t.longitude))
  end

  def recent(query, limit \\ 10) do
    query
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def earliest_first(query) do
    order_by(query, asc: :inserted_at)
  end
end
