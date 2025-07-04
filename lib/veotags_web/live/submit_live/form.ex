defmodule VeotagsWeb.SubmitLive.Form do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping
  alias Veotags.Mapping.Tag

  alias VeotagsWeb.SubmitLive.MapPicker

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <main class="px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-2xl space-y-4">
          <.header>
            {@page_title}
            <:subtitle>Use this form to manage tag records in your database.</:subtitle>
          </.header>

          <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
            <fieldset class="fieldset mb-2">
              <label>
                <span class="label mb-1">Photo</span>
                <.live_file_input
                  upload={@uploads[:photo]}
                  required="true"
                  class="file-input file-input-primary block"
                />
              </label>
            </fieldset>

            <MapPicker.map_picker coord={%{lat: @form[:latitude].value, lng: @form[:longitude].value}} />

            <.input field={@form[:address]} type="text" label="Address" required="true" />
            <.input field={@form[:email]} type="text" label="Email" />
            <.input field={@form[:comment]} type="textarea" label="Comment" />

            <footer>
              <.button phx-disable-with="Saving..." variant="primary">Save Tag</.button>
            </footer>
          </.form>
        </div>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)
     |> allow_upload(:photo, accept: Veotags.Photo.allowed_extensions())}
  end

  @impl true
  def handle_info({:update_location, %{id: "map-picker", lat: lat, lng: lng}}, socket) do
    new_params = Map.merge(socket.assigns.form.params, %{"latitude" => lat, "longitude" => lng})
    socket = assign(socket, form: to_form(Mapping.change_tag(%Tag{}, new_params)))
    {:noreply, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

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
    [file_path] =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    tag_params = Map.put(tag_params, "photo", file_path)

    save_tag(socket, socket.assigns.live_action, tag_params)
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
