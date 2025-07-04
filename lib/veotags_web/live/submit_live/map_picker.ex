defmodule VeotagsWeb.SubmitLive.MapPicker do
  use VeotagsWeb, :live_component

  attr :id, :string, default: "map-picker", doc: "Unique ID for the map picker"
  attr :coord, :map, default: nil, doc: "Coordinates for the marker"

  def map_picker(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} coord={@coord} />
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
      if changed?(socket, :coord) do
        push_marker(socket, socket.assigns.coord)
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="MapPickerHook"
      phx-target={@myself}
      data-lat={@coord[:lat]}
      data-lng={@coord[:lng]}
      phx-update="ignore"
    >
      <div id="map" style="height: 400px;"></div>
    </div>
    """
  end

  def handle_event("map_clicked", %{"lat" => lat, "lng" => lng}, socket) do
    new_location = %{id: socket.assigns.id, lat: String.to_float(lat), lng: String.to_float(lng)}
    send(self(), {:update_location, new_location})
    {:noreply, socket}
  end

  defp push_marker(socket, coord) do
    push_event(socket, "move_to", coord)
  end
end
