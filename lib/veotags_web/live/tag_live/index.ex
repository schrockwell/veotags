defmodule VeotagsWeb.TagLive.Index do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.container>
        <.header>
          Approval Queue
        </.header>

        <.table
          id="tags"
          rows={@tags}
          row_click={fn tag -> JS.navigate(~p"/admin/tags/#{tag}/edit") end}
        >
          <:col :let={tag} label="Image">
            <img
              src={photo_url(tag)}
              alt="Tag Photo"
              class="rounded-box aspect-square w-32 h-32 object-cover"
            />
          </:col>
          <:col :let={tag} label="Submitted">{date(tag.submitted_at)}</:col>
          <:col :let={tag} label="Reporter">{tag.reporter || "-"}</:col>
        </.table>
      </.container>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Veotags.PubSub, "tags")

    {:ok,
     socket
     |> assign(:page_title, "Approval Queue")
     |> load_tags()}
  end

  @impl true
  def handle_info(:load_tags, socket) do
    {:noreply, load_tags(socket)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp load_tags(socket) do
    socket
    |> assign(:tags, Mapping.list_submitted_tags())
  end
end
