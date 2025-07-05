defmodule Veotags.Mapping do
  @moduledoc """
  The Mapping context.
  """

  import Ecto.Query, warn: false
  alias Veotags.Repo
  alias Veotags.Photo

  alias Veotags.Mapping.Tag

  require Logger

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    case Repo.delete(tag) do
      {:ok, tag} ->
        Photo.delete(tag.photo.file_name)
        {:ok, tag}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  def count_tags do
    Tag |> Tag.approved() |> Repo.aggregate(:count, :id)
  end

  def approve_tag(%Tag{} = tag) do
    tag
    |> Tag.approve_changeset()
    |> Repo.update()
  end

  def list_recent_tags(opts \\ []) do
    Tag
    |> Tag.approved()
    |> Tag.recent(opts[:limit] || 10)
    |> Repo.all()
  end

  def photo_url(%Tag{} = tag) do
    if tag.photo_url == nil or
         tag.photo_url_expires_at == nil or
         DateTime.compare(tag.photo_url_expires_at, DateTime.utc_now()) == :lt do
      update_photo_url(tag)
    else
      tag.photo_url
    end
  end

  defp update_photo_url(%Tag{} = tag) do
    Logger.debug("Generating presigned URL for tag #{tag.id}")

    case Photo.presigned_url(tag.photo) do
      {:ok, url, expires_at} ->
        tag
        |> Ecto.Changeset.change(photo_url: url, photo_url_expires_at: expires_at)
        |> Repo.update!()
        |> Map.get(:photo_url)

      _ ->
        nil
    end
  end
end
