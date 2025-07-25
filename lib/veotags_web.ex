defmodule VeotagsWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use VeotagsWeb, :controller
      use VeotagsWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths do
    [
      "android-chrome-192x192.png",
      "android-chrome-512x512.png",
      "apple-touch-icon.png",
      "assets",
      "favicon-16x16.png",
      "favicon-32x32.png",
      "favicon.ico",
      "fonts",
      "images",
      "robots.txt",
      "site.webmanifest"
    ]
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: VeotagsWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: VeotagsWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      use PhoenixHTMLHelpers

      # Core UI components
      import VeotagsWeb.CoreComponents
      import VeotagsWeb.Helpers

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias VeotagsWeb.Layouts
      alias VeotagsWeb.SVG

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: VeotagsWeb.Endpoint,
        router: VeotagsWeb.Router,
        statics: VeotagsWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
