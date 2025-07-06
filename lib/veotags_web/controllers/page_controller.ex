defmodule VeotagsWeb.PageController do
  use VeotagsWeb, :controller

  def about(conn, _params) do
    conn
    |> assign(:page_title, "About")
    |> render()
  end
end
