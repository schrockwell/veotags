defmodule VeotagsWeb.Helpers do
  alias Veotags.Mapping.Tag
  alias Veotags.Photo

  def date(datetime) do
    Calendar.strftime(datetime, "%B %-d, %Y")
  end

  def tag_title(%Tag{comment: comment}) when is_binary(comment) and comment != "", do: comment
  def tag_title(%Tag{id: id}), do: "VEOtag ##{id}"

  def photo_url(%Tag{} = tag, version \\ :px2000) do
    Photo.url({tag.photo, tag}, version, [])
  end
end
