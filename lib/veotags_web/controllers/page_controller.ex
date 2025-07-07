defmodule VeotagsWeb.PageController do
  use VeotagsWeb, :controller

  def up(conn, _params) do
    tag_count = Veotags.Mapping.count_tags()
    text(conn, "#{tag_count} tags and counting...")
  end

  def about(conn, _params) do
    conn
    |> assign(:page_title, "About")
    |> render()
  end
end
