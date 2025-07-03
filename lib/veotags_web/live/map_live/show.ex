defmodule VeotagsWeb.MapLive.Show do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:tag, nil)
      |> push_markers()

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex-1 flex items-stretch">
        <div class={"lg:w-1/3 bg-base-200 p-4 overflow-y-scroll #{sidebar_column_class(@tag)}"}>
          <.tag_details :if={@tag} tag={@tag} />

          <div :if={!@tag}>
            <p class="text-sm text-gray-500">Select a tag to see details</p>
          </div>
        </div>

        <div class={"relative #{map_column_class(@tag)}"}>
          <div id="map" phx-hook="MapHook" phx-update="ignore" class="absolute inset-0" />
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp tag_details(assigns) do
    ~H"""
    <div class="flex flex-col gap-8">
      <div class="flex justify-between items-start">
        <h3 class="text-xl font-medium mt-2">{@tag.address}</h3>

        <button phx-click="clear_tag" class="btn btn-circle btn-neutral btn-lg">
          <.icon name="hero-x-mark" class="w-6 h-6" />
        </button>
      </div>

      <img src={Veotags.Photo.presigned_url(@tag.photo)} class="w-full rounded-box" />

      <div class="overflow-x-auto rounded-box border border-base-content/5 bg-base-100">
        <table class="table">
          <tbody>
            <tr :if={@tag.reporter}>
              <th>Spotted By</th>
              <td>{@tag.reporter}</td>
            </tr>
            <tr>
              <th>Location</th>
              <td>
                <div>{coordinate(@tag)}</div>
                <div class="flex gap-2">
                  <.link href={"https://www.google.com/maps/search/?api=1&query=#{coordinate(@tag)}"} class="link link-primary flex items-center gap-1" target="_blank">
                    Google
                    <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 inline-block" />
                  </.link>
                  <.link href={"https://www.openstreetmap.org/search?lat=#{@tag.latitude}&lon=#{@tag.longitude}&zoom=17"} class="link link-primary flex items-center gap-1" target="_blank">
                    OpenStreetMap
                    <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 inline-block" />
                  </.link>
                </div>
              </td>
            </tr>
            <tr :if={@tag.radius != 0}>
              <th>Precision</th>
              <td>±{@tag.radius/1000}km</td>
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
  defp latitude(lat), do: "#{lat}°N"

  defp longitude(lng) when lng < 0, do: "#{abs(lng)}° W"
  defp longitude(lng), do: "#{lng}° E"

  defp sidebar_column_class(nil), do: "hidden lg:block"
  defp sidebar_column_class(_tag), do: "block"

  defp map_column_class(nil), do: "flex-1"
  defp map_column_class(_tag), do: "flex-1 hidden lg:block"

  defp push_markers(socket) do
    markers =
      Enum.map(Mapping.list_tags(), fn tag ->
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
    {:noreply, assign(socket, :tag, Mapping.get_tag!(id))}
  end

  def handle_event("marker_deselected", _params, socket) do
    {:noreply, assign(socket, :tag, nil)}
  end

  def handle_event("clear_tag", _params, socket) do
    {:noreply, socket |> assign(:tag, nil) |> push_event("close_popups", %{id: "map"})}
  end
end
