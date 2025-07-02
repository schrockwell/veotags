defmodule VeotagsWeb.PageController do
  use VeotagsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
