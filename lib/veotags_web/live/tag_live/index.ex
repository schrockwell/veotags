defmodule VeotagsWeb.TagLive.Index do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.container>
        <.header>Approval Queue</.header>

        <.table
          id="tags"
          rows={@streams.tags}
          row_click={fn {_id, tag} -> JS.navigate(~p"/admin/tags/#{tag}/edit") end}
        >
          <:col :let={{_id, tag}} label="Image">
            <img
              src={Mapping.photo_url(tag)}
              alt="Tag Photo"
              class="rounded-box aspect-square w-32 h-32 object-cover"
            />
          </:col>
          <:col :let={{_id, tag}} label="Submitted">{date(tag.submitted_at)}</:col>
          <:col :let={{_id, tag}} label="Reporter">{tag.reporter || "-"}</:col>
        </.table>
      </.container>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Approval Queue")
     |> stream(:tags, Mapping.list_submitted_tags())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tag = Mapping.get_tag!(id)
    {:ok, _} = Mapping.delete_tag(tag)

    {:noreply, stream_delete(socket, :tags, tag)}
  end
end
