defmodule VeotagsWeb.SubmitLive.Form do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping
  alias Veotags.Mapping.Tag

  alias VeotagsWeb.SubmitLive.MapPicker

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.container>
        <.header>Submit a VEOtag</.header>

        <%= if @step == 1 do %>
          <.form
            for={@form}
            id="photo-form"
            phx-change="validate-photo"
            phx-submit="save-photo"
            phx-hook="PhotoFormHook"
          >
            <fieldset class="fieldset mb-2">
              <label for={@uploads.photo.ref} phx-drop-target={@uploads.photo.ref}>
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
          <img src={photo_url(@tag)} class="rounded-box mb-8" />
        <% end %>

        <%= if @step >= 2 do %>
          <.form
            for={@form}
            id="tag-form"
            phx-change="validate"
            phx-submit="save"
            phx-hook="SubmitFormHook"
          >
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

              <.error :if={
                @form.action == :insert &&
                  (@form[:latitude].errors != [] || @form[:longitude].errors != [])
              }>
                Provide a location, or select "Unknown"
              </.error>
            </fieldset>

            <h3 class="text-xl mb-2">Details</h3>

            <.input
              field={@form[:comment]}
              type="text"
              label="Comment"
              placeholder="Optional"
              hint="Describe the location of this tag (200 characters max)."
              maxlength="200"
            />

            <.input
              field={@form[:reporter]}
              type="text"
              label="Reported By"
              placeholder="Anonymous"
              hint="Provide your name or online handle if you want credit for submitting this photo."
            />

            <.input
              field={@form[:email]}
              type="text"
              label="E-mail"
              placeholder="Optional"
              hint="Your e-mail will never be published or subscribed to anything. It's only used to to contact you
                about the details of this listing."
            />

            <footer>
              <.button phx-disable-with="Submitting..." variant="primary">Submit</.button>
            </footer>
          </.form>
        <% end %>
      </.container>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Submit")
     |> assign(:step, 1)
     |> assign(:tag, %Tag{})
     |> assign(:form, to_form(Mapping.change_tag(%Tag{})))
     |> allow_upload(:photo, accept: Veotags.Photo.allowed_extensions())}
  end

  @impl true
  def handle_info({:update_location, %{id: "map-picker", lat: lat, lng: lng}}, socket) do
    new_params = Map.merge(socket.assigns.form.params, %{"latitude" => lat, "longitude" => lng})

    socket =
      assign(socket,
        form: to_form(Mapping.change_tag(socket.assigns.tag, new_params), action: :validate)
      )

    {:noreply, socket}
  end

  @impl true

  # required for live_file_input to work
  def handle_event("validate-photo", _params, socket) do
    {:noreply, push_event(socket, "submit", %{id: "photo-form"})}
  end

  def handle_event("save-photo", _params, socket) do
    [file_path] =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)

    %{"photo" => file_path}
    |> Map.merge(extract_gps_coordinates(file_path))
    |> Mapping.create_initial_tag()
    |> case do
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
    submit_tag(socket, socket.assigns.live_action, tag_params)
  end

  defp advance_step(%{assigns: %{step: 1, tag: %{photo: photo}}} = socket)
       when not is_nil(photo) do
    assign(socket, step: 2)
  end

  defp advance_step(socket) do
    socket
  end

  defp submit_tag(socket, :new, tag_params) do
    case Mapping.submit_tag(socket.assigns.tag, tag_params) do
      {:ok, _tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag submitted for review")
         |> push_navigate(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :insert))}
    end
  end

  defp extract_gps_coordinates(file_path) do
    with "image/jpeg" <- MIME.from_path(file_path),
         {:ok,
          %{
            gps: %{
              gps_latitude: [lat_deg, lat_min, lat_sec],
              gps_latitude_ref: lat_ref,
              gps_longitude: [lng_deg, lng_min, lng_sec],
              gps_longitude_ref: lng_ref
            }
          }} <- Exexif.exif_from_jpeg_file(file_path) do
      lat = (lat_deg + lat_min / 60 + lat_sec / 3600) * if(lat_ref == "N", do: 1, else: -1)
      lng = (lng_deg + lng_min / 60 + lng_sec / 3600) * if(lng_ref == "E", do: 1, else: -1)

      %{"latitude" => lat, "longitude" => lng, "accuracy" => "exact"}
    else
      _ -> %{}
    end
  rescue
    # Exexif can raise - see this issue: https://github.com/pragdave/exexif/issues/14
    _ -> %{}
  end
end
