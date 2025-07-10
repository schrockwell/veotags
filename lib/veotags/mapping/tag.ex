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
    field :latitude, :float
    field :longitude, :float
    field :title, :string
    field :comment, :string
    field :source_url, :string
    field :submitted_at, :utc_datetime
    field :approved_at, :utc_datetime
    field :accuracy, :string, default: "approximate"

    embeds_many :reporters, Veotags.Mapping.Reporter, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def accuracy_options, do: @accuracy_options

  def mappable?(%__MODULE__{latitude: nil, longitude: nil}), do: false
  def mappable?(_tag), do: true

  ### CHANGESETS  ***

  def initial_changeset(tag, attrs) do
    cast(tag, attrs, [:latitude, :longitude, :accuracy])
  end

  def submit_changeset(tag, attrs) do
    tag
    |> cast(attrs, [
      :latitude,
      :longitude,
      :accuracy,
      :title,
      :comment,
      :source_url,
      :submitted_at
    ])
    |> cast_embed(:reporters)
    |> put_submitted_at()
    |> validate_location()
    |> validate_length(:comment, max: 200)
    |> validate_length(:title, max: 200)
  end

  def attach_photo_changeset(changeset, attrs) do
    changeset
    |> cast_attachments(attrs, [:photo], allow_paths: true)
    |> validate_required([:photo])
  end

  defp put_submitted_at(changeset) do
    if get_field(changeset, :submitted_at) do
      changeset
    else
      change(changeset, submitted_at: DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end

  def approve_changeset(tag) do
    change(tag,
      approved_at: DateTime.utc_now() |> DateTime.truncate(:second)
    )
  end

  def delist_changeset(tag) do
    change(tag, approved_at: nil)
  end

  ### VALIDATIONS ###

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

  ### QUERIES ###

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
