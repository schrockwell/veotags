defmodule VeotagsWeb.TagLive.Index do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tags
        <:actions>
          <.button variant="primary" navigate={~p"/tags/new"}>
            <.icon name="hero-plus" /> New Tag
          </.button>
        </:actions>
      </.header>

      <.table
        id="tags"
        rows={@streams.tags}
        row_click={fn {_id, tag} -> JS.navigate(~p"/tags/#{tag}") end}
      >
        <:col :let={{_id, tag}} label="Approved">{tag.approved_at != nil}</:col>
        <:action :let={{_id, tag}}>
          <div class="sr-only">
            <.link navigate={~p"/tags/#{tag}"}>Show</.link>
          </div>
          <.link navigate={~p"/tags/#{tag}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, tag}}>
          <.link
            phx-click={JS.push("delete", value: %{id: tag.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Tags")
     |> stream(:tags, Mapping.list_tags())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tag = Mapping.get_tag!(id)
    {:ok, _} = Mapping.delete_tag(tag)

    {:noreply, stream_delete(socket, :tags, tag)}
  end
end
