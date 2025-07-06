defmodule VeotagsWeb.MapLive.Show do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping
  alias Veotags.Mapping.Tag

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:tag, nil)
      |> assign(:tag_count, Mapping.count_tags())
      |> assign(:recent_tags, Mapping.list_recent_tags(limit: 10))
      |> push_markers()

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.map flash={@flash}>
      <!-- Sidebar -->
      <aside class={"lg:w-1/3 bg-base-200 p-4 overflow-y-auto #{sidebar_column_class(@tag)}"}>
        <.tag_details :if={@tag} tag={@tag} />

        <div :if={!@tag}>
          <h3 class="text-2xl font-medium mb-6">Recent VEOtags</h3>

          <div class="grid grid-cols-2 xl:grid-cols-3 gap-5">
            <.tag_card :for={tag <- @recent_tags} tag={tag} />
          </div>
        </div>
      </aside>
      
    <!-- Map area -->
      <div class={"relative #{map_column_class(@tag)}"}>
        <div id="map" phx-hook="MapHook" phx-update="ignore" class="absolute inset-0 z-0" />
      </div>
    </Layouts.map>
    """
  end

  defp tag_card(assigns) do
    ~H"""
    <button
      class="transition-transform hover:scale-105 cursor-pointer"
      phx-click="preview_selected"
      phx-value-id={@tag.id}
    >
      <figure>
        <img src={Mapping.photo_url(@tag)} class="aspect-square object-cover rounded-lg" />
      </figure>
    </button>
    """
  end

  defp tag_details(assigns) do
    assigns = Map.put(assigns, :photo_url, Mapping.photo_url(assigns.tag))

    ~H"""
    <div class="flex flex-col gap-8">
      <div class="flex justify-between items-start">
        <h3 class="text-xl font-medium mt-2">{@tag.address}</h3>

        <button phx-click="clear_tag" class="btn btn-circle btn-neutral btn-lg">
          <.icon name="hero-x-mark" class="w-6 h-6" />
        </button>
      </div>

      <.link href={@photo_url} target="_blank">
        <img src={@photo_url} class="w-full rounded-box" />
      </.link>

      <div class="overflow-x-auto rounded-box border border-base-content/5 bg-base-100">
        <table class="table">
          <tbody>
            <tr :if={@tag.reporter}>
              <th>Source</th>
              <td>
                {@tag.reporter}
                <div :if={@tag.source_url}>
                  <.link href={@tag.source_url} target="_blank" class="link link-primary">
                    {URI.parse(@tag.source_url).host}
                  </.link>
                </div>
              </td>
            </tr>
            <tr>
              <th>Location</th>
              <td :if={Tag.mappable?(@tag)}>
                <div>{coordinate(@tag)} ({@tag.accuracy})</div>
                <div class="flex gap-2">
                  <.link
                    href={"https://www.google.com/maps/search/?api=1&query=#{coordinate(@tag)}"}
                    class="link link-primary flex items-center gap-1"
                    target="_blank"
                  >
                    Google
                    <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 inline-block" />
                  </.link>
                  <.link
                    href={"https://www.openstreetmap.org/search?lat=#{@tag.latitude}&lon=#{@tag.longitude}&zoom=17"}
                    class="link link-primary flex items-center gap-1"
                    target="_blank"
                  >
                    OpenStreetMap
                    <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 inline-block" />
                  </.link>
                </div>
              </td>
              <td :if={!Tag.mappable?(@tag)}>Unknown</td>
            </tr>
            <tr>
              <th>Submitted</th>
              <td>{@tag.inserted_at}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div :if={@tag.comment}>
        <h3 class="text-lg font-medium">Comment</h3>
        <div class="prose">{text_to_html(@tag.comment)}</div>
      </div>
    </div>
    """
  end

  defp coordinate(tag), do: "#{latitude(tag.latitude)}, #{longitude(tag.longitude)}"

  defp latitude(lat) when lat < 0, do: "#{abs(lat)}° S"
  defp latitude(lat), do: "#{lat}° N"

  defp longitude(lng) when lng < 0, do: "#{abs(lng)}° W"
  defp longitude(lng), do: "#{lng}° E"

  defp sidebar_column_class(nil), do: "hidden lg:block"
  defp sidebar_column_class(_tag), do: "block"

  defp map_column_class(nil), do: "flex-1"
  defp map_column_class(_tag), do: "flex-1 hidden lg:block"

  defp push_markers(socket) do
    markers =
      Enum.map(Mapping.list_mappable_tags(), fn tag ->
        %{
          id: tag.id,
          lat: tag.latitude,
          lng: tag.longitude,
          address: tag.address
        }
      end)

    push_event(socket, "put_markers", %{id: "map", markers: markers})
  end

  def handle_event("marker_selected", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:tag, Mapping.get_tag!(id))}
  end

  def handle_event("preview_selected", %{"id" => id}, socket) do
    tag = Mapping.get_tag!(id)

    socket =
      if Tag.mappable?(tag) do
        push_event(socket, "select_marker", %{id: "map", marker_id: id})
      else
        socket
      end

    {:noreply, assign(socket, :tag, Mapping.get_tag!(id))}
  end

  def handle_event("marker_deselected", _params, socket) do
    {:noreply, assign(socket, :tag, nil)}
  end

  def handle_event("clear_tag", _params, socket) do
    {:noreply, socket |> assign(:tag, nil) |> push_event("close_popups", %{id: "map"})}
  end
end
