defmodule VeotagsWeb.MapLive.Show do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  def mount(_params, _session, socket) do
    socket = push_markers(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="map" phx-hook="MapHook" phx-update="ignore" class="w-full h-[500px]" />
    </Layouts.app>
    """
  end

  defp push_markers(socket) do
    markers =
      Enum.map(Mapping.list_tags(), fn tag ->
        %{
          id: tag.id,
          lat: tag.latitude,
          lng: tag.longitude,
          popup: tag.address
        }
      end)

    push_event(socket, "add_markers", %{id: "map", markers: markers})
  end
end
