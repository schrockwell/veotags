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
          <.header>{@page_title}</.header>

          <%= if @step == 1 do %>
            <.form for={@form} id="photo-form" phx-change="validate-photo" phx-submit="save-photo">
              <fieldset class="fieldset mb-2">
                <label>
                  <.live_file_input
                    upload={@uploads.photo}
                    required="true"
                    class="file-input file-input-primary block"
                  />
                </label>
              </fieldset>

              <.button type="submit" phx-disable-with="Uploading..." variant="primary">
                Continue
              </.button>
            </.form>
          <% else %>
            <img src={Mapping.photo_url(@tag)} class="rounded-box mb-8" />
          <% end %>

          <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
            <%= if @step >= 2 do %>
              <fieldset class="mb-8">
                <h3 class="text-xl mb-2">Location</h3>

                <.input
                  field={@form[:accuracy]}
                  type="select"
                  class="w-auto select"
                  options={Tag.accuracy_options()}
                />

                <MapPicker.map_picker
                  lat_field={@form[:latitude]}
                  lng_field={@form[:longitude]}
                  disabled={@form[:accuracy].value == "unknown"}
                />
              </fieldset>
            <% end %>

            <%= if @step >= 3 do %>
              <.input field={@form[:reporter]} type="text" label="Username" />
              <.input field={@form[:email]} type="text" label="Email" />

              <footer>
                <.button phx-disable-with="Saving..." variant="primary">Submit</.button>
              </footer>
            <% end %>
          </.form>
        </div>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Submit a VEOtag")
     |> assign(:step, 1)
     |> assign(:tag, %Tag{})
     |> assign(:form, to_form(Mapping.change_tag(%Tag{})))
     |> allow_upload(:photo, accept: Veotags.Photo.allowed_extensions())}
  end

  @impl true
  def handle_info({:update_location, %{id: "map-picker", lat: lat, lng: lng}}, socket) do
    new_params = Map.merge(socket.assigns.form.params, %{"latitude" => lat, "longitude" => lng})
    socket = assign(socket, form: to_form(Mapping.change_tag(socket.assigns.tag, new_params)))
    {:noreply, socket}
  end

  @impl true

  def handle_event("validate-photo", _params, socket) do
    # required for live_file_input to work
    {:noreply, socket}
  end

  def handle_event("save-photo", _params, socket) do
    [file_path] =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    case Mapping.create_initial_tag(%{"photo" => file_path}) do
      {:ok, tag} ->
        socket =
          socket
          |> assign(tag: tag)
          |> assign(form: to_form(Mapping.change_tag(tag)))
          |> advance_step()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(form: to_form(changeset))

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"tag" => tag_params}, socket) do
    tag_params =
      case tag_params do
        %{"accuracy" => "unknown"} ->
          Map.merge(tag_params, %{"latitude" => nil, "longitude" => nil})

        _ ->
          tag_params
      end

    changeset = Mapping.change_tag(socket.assigns.tag, tag_params)

    socket =
      socket
      |> assign(form: to_form(changeset, action: :validate))
      |> advance_step()

    {:noreply, socket}
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

  defp advance_step(%{assigns: %{step: 1, tag: %{photo: photo}}} = socket)
       when not is_nil(photo) do
    assign(socket, step: 2)
  end

  defp advance_step(socket) do
    socket
  end

  defp save_tag(socket, :new, tag_params) do
    case Mapping.submit_tag(tag_params) do
      {:ok, _tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag submitted for review")
         |> push_navigate(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
