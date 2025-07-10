defmodule VeotagsWeb.Helpers do
  alias Veotags.Mapping.Tag
  alias Veotags.Photo

  def date(datetime) do
    Calendar.strftime(datetime, "%B %-d, %Y")
  end

  def tag_title(%Tag{title: title}) when is_binary(title) and title != "", do: title
  def tag_title(%Tag{id: id}), do: "VEOtag ##{id}"

  def photo_url(%Tag{} = tag, version \\ :px2000) do
    Photo.url({tag.photo, tag}, version, [])
  end

  def tag_reporter_names(%Tag{reporters: reporters}) do
    reporters
    |> Enum.map(& &1.name)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> ["Anonymous"]
      names -> names
    end
  end
end
