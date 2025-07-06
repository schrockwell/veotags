defmodule VeotagsWeb.TagLive.Show do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Tag {@tag.id}
        <:subtitle>This is a tag record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/tags"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tags/#{@tag}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit tag
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Address">{@tag.address}</:item>
        <:item title="Latitude">{@tag.latitude}</:item>
        <:item title="Longitude">{@tag.longitude}</:item>
        <:item title="Accuracy">{@tag.accuracy}</:item>
        <:item title="Email">{@tag.email}</:item>
        <:item title="Comment">{@tag.comment}</:item>
        <:item title="Approved at">{@tag.approved_at}</:item>
        <:item title="Photo">
          <img src={Mapping.photo_url(@tag)} />
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Tag")
     |> assign(:tag, Mapping.get_tag!(id))}
  end
end
