defmodule VeotagsWeb.SubmitLive.MapPicker do
  use VeotagsWeb, :live_component

  attr :id, :string, default: "map-picker", doc: "Unique ID for the map picker"
  attr :lat_field, :map
  attr :lng_field, :map
  attr :disabled, :boolean, default: false, doc: "Whether the map picker is disabled"

  def map_picker(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      lat_field={@lat_field}
      lng_field={@lng_field}
      disabled={@disabled}
    />
    """
  end

  def mount(socket) do
    socket =
      socket
      |> assign(:id, "map-picker")

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      if changed?(socket, :lat_field) or changed?(socket, :lng_field) do
        push_marker(socket)
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[disabled_class(@disabled), "rounded-box overflow-hidden"]}>
      <input type="hidden" name={@lat_field.name} value={@lat_field.value} />
      <input type="hidden" name={@lng_field.name} value={@lng_field.value} />

      <div
        id={@id}
        phx-hook="MapPickerHook"
        phx-target={@myself}
        data-lat={@lat_field.value}
        data-lng={@lng_field.value}
        phx-update="ignore"
      >
        <div id="map" style="height: 400px;"></div>
      </div>
    </div>
    """
  end

  def handle_event("map_clicked", %{"lat" => lat, "lng" => lng}, socket) do
    new_location = %{id: socket.assigns.id, lat: String.to_float(lat), lng: String.to_float(lng)}
    send(self(), {:update_location, new_location})
    {:noreply, socket}
  end

  defp push_marker(socket) do
    push_event(socket, "move_to", %{
      lat: socket.assigns.lat_field.value,
      lng: socket.assigns.lng_field.value
    })
  end

  defp disabled_class(true), do: "pointer-events-none opacity-50"
  defp disabled_class(false), do: ""
end
