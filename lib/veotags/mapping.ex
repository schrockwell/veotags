defmodule Veotags.Mapping do
  @moduledoc """
  The Mapping context.
  """

  import Ecto.Query, warn: false
  alias Veotags.Photo
  alias Veotags.Repo
  alias Veotags.Reddit

  alias Veotags.Mapping.ImportedLink
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

  def list_submitted_tags do
    Tag
    |> Tag.submitted()
    |> Tag.earliest_first()
    |> Repo.all()
  end

  def list_approved_tags do
    Tag
    |> Tag.approved()
    |> Repo.all()
  end

  def list_mappable_tags do
    Tag
    |> Tag.approved()
    |> Tag.with_coordinates()
    |> Repo.all()
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

  def get_tag_by!(clauses), do: Repo.get_by!(Tag, clauses)

  def create_initial_tag(attrs) do
    submit_tag(attrs)
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def submit_tag(tag \\ %Tag{}, attrs) do
    tag
    |> Tag.submit_changeset(attrs)
    |> Repo.insert_or_update()
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
    |> Tag.submit_changeset(attrs)
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
    Tag.submit_changeset(tag, attrs)
  end

  def count_tags do
    Tag |> Tag.approved() |> Repo.aggregate(:count, :id)
  end

  def approve_tag(%Tag{} = tag) do
    tag
    |> Tag.approve_changeset(next_tag_number())
    |> Repo.update()
  end

  def delist_tag(%Tag{} = tag) do
    tag
    |> Tag.delist_changeset()
    |> Repo.update()
  end

  defp next_tag_number do
    Tag
    |> Repo.aggregate(:max, :number)
    |> case do
      nil -> 1
      max -> max + 1
    end
  end

  def list_recent_tags(opts \\ []) do
    Tag
    |> Tag.approved()
    |> Tag.recent(opts[:limit] || 10)
    |> Repo.all()
  end

  def photo_url(%Tag{} = tag) do
    Photo.url(tag.photo)
  end

  def delete_abandoned_submissions do
    Tag
    |> Tag.abandoned()
    |> Repo.all()
    |> Enum.each(fn tag ->
      delete_tag(tag)
    end)
  end

  def enqueue_new_from_reddit do
    case Reddit.fetch_latest() do
      {:ok, posts_params, _after_name} ->
        new_reddit_names = Enum.map(posts_params, & &1.reddit_name)

        existing_reddit_names =
          ImportedLink
          |> where([t], t.name in ^new_reddit_names)
          |> select([t], t.name)
          |> Repo.all()

        inserted_count =
          posts_params
          |> Enum.reject(&(&1.reddit_name in existing_reddit_names))
          |> Enum.map(fn params ->
            case create_initial_tag(params) do
              {:ok, tag} ->
                Repo.insert!(%ImportedLink{name: tag.reddit_name})

                Logger.info("Created tag #{tag.id} from Reddit post #{tag.reddit_name}")
                1

              {:error, changeset} ->
                Logger.error("Failed to create tag from Reddit post: #{inspect(changeset)}")
                0
            end
          end)
          |> Enum.sum()

        Logger.info("Inserted #{inserted_count} new tags")
        {:ok, inserted_count}

      :error ->
        {:error, "Failed to fetch latest posts from Reddit"}
    end
  end

  def random_tag do
    Tag
    |> Tag.approved()
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end
end
