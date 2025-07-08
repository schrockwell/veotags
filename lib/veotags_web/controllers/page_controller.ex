defmodule VeotagsWeb.PageController do
  use VeotagsWeb, :controller

  def about(conn, _params) do
    conn
    |> assign(:page_title, "About")
    |> assign(:hero_url, VeotagsWeb.Helpers.photo_url(Veotags.Mapping.random_tag()))
    |> render()
  end

  def admin(conn, _params) do
    redirect(conn, to: "/admin/tags")
  end

  def up(conn, _params) do
    tag_count = Veotags.Mapping.count_tags()
    text(conn, "#{tag_count} tags and counting...")
  end
end
