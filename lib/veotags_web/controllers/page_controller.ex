defmodule VeotagsWeb.PageController do
  use VeotagsWeb, :controller

  def about(conn, _params) do
    hero_tag = Veotags.Mapping.random_tag()
    hero_url = Veotags.Mapping.photo_url(hero_tag)

    conn
    |> assign(:page_title, "About")
    |> assign(:hero_url, hero_url)
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
