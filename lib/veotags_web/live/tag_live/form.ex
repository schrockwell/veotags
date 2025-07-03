defmodule VeotagsWeb.TagLive.Form do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping
  alias Veotags.Mapping.Tag

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage tag records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:address]} type="text" label="Address" />
        <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
        <.input field={@form[:radius]} type="number" label="Radius" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:comment]} type="textarea" label="Comment" />
        <.input field={@form[:approved_at]} type="datetime-local" label="Approved at" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tag</.button>
          <.button navigate={return_path(@return_to, @tag)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    tag = Mapping.get_tag!(id)

    socket
    |> assign(:page_title, "Edit Tag")
    |> assign(:tag, tag)
    |> assign(:form, to_form(Mapping.change_tag(tag)))
  end

  defp apply_action(socket, :new, _params) do
    tag = %Tag{}

    socket
    |> assign(:page_title, "New Tag")
    |> assign(:tag, tag)
    |> assign(:form, to_form(Mapping.change_tag(tag)))
  end

  @impl true
  def handle_event("validate", %{"tag" => tag_params}, socket) do
    changeset = Mapping.change_tag(socket.assigns.tag, tag_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    save_tag(socket, socket.assigns.live_action, tag_params)
  end

  defp save_tag(socket, :edit, tag_params) do
    case Mapping.update_tag(socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tag))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tag(socket, :new, tag_params) do
    case Mapping.create_tag(tag_params) do
      {:ok, tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tag))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _tag), do: ~p"/tags"
  defp return_path("show", tag), do: ~p"/tags/#{tag}"
end
