defmodule VeotagsWeb.Router do
  use VeotagsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VeotagsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VeotagsWeb do
    pipe_through :browser

    live "/", MapLive.Show, :show
    live "/tags/:number", MapLive.Show, :show
    live "/submit", SubmitLive.Form, :new

    get "/about", PageController, :about
    get "/up", PageController, :up
  end

  scope "/admin", VeotagsWeb do
    pipe_through [:browser, :admin]

    live "/tags", TagLive.Index, :index
    live "/tags/:id/edit", TagLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", VeotagsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:veotags, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VeotagsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp auth(conn, _opts) do
    Plug.BasicAuth.basic_auth(conn,
      username: "admin",
      password: System.fetch_env!("ADMIN_PASSWORD")
    )
  end
end
