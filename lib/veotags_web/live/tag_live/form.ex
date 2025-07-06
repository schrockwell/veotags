defmodule VeotagsWeb.TagLive.Form do
  use VeotagsWeb, :live_view

  alias Veotags.Mapping
  alias Veotags.Mapping.Tag

  alias VeotagsWeb.SubmitLive.MapPicker

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.container>
        <img src={Mapping.photo_url(@tag)} alt="Tag Photo" class="rounded-box max-h-[500px] mx-auto" />

        <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
          <.live_file_input upload={@uploads[:photo]} class="file-input mb-4" />
          <.input
            field={@form[:accuracy]}
            type="select"
            options={Tag.accuracy_options()}
            label="Accuracy"
          />

          <MapPicker.map_picker
            lat_field={@form[:latitude]}
            lng_field={@form[:longitude]}
            disabled={@form[:accuracy].value == "unknown"}
          />

          <.input field={@form[:reporter]} type="text" label="Reporter" />
          <.input field={@form[:email]} type="text" label="Email" />
          <.input field={@form[:comment]} type="text" label="Comment" required="true" />

          <footer>
            <%= if @tag.approved_at do %>
              <input type="submit" name="action" value="Save" class="btn btn-primary" />
              <input type="submit" name="action" value="Delist" class="btn" />
              <input type="submit" name="action" value="Delete" class="btn" />
            <% else %>
              <input type="submit" name="action" value="Approve" class="btn btn-primary" />
              <input type="submit" name="action" value="Save" class="btn" />
              <input type="submit" name="action" value="Delete" class="btn" />
            <% end %>
          </footer>
        </.form>
      </.container>
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

    socket =
      assign(socket,
        form: to_form(Mapping.change_tag(socket.assigns.tag, new_params), action: :validate)
      )

    {:noreply, socket}
  end

  defp return_to("edit"), do: "edit"
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

  def handle_event("save", %{"action" => "Delete"}, socket) do
    case Mapping.delete_tag(socket.assigns.tag) do
      {:ok, _tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag deleted successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, nil))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to delete tag")}
    end
  end

  def handle_event("save", %{"action" => action, "tag" => tag_params}, socket) do
    tag_params =
      socket
      |> consume_uploaded_entries(:photo, fn %{path: path}, entry ->
        IO.inspect(entry, label: "Uploaded Entry")
        # Add the file extension to the temp file
        path_with_extension = path <> String.replace(entry.client_type, "image/", ".")
        File.cp!(path, path_with_extension)
        {:ok, path_with_extension}
      end)
      |> case do
        [file_path] -> Map.put(tag_params, "photo", file_path)
        [] -> tag_params
      end

    save_tag(socket, socket.assigns.live_action, tag_params, action)
  end

  defp save_tag(socket, :edit, tag_params, action) do
    case Mapping.update_tag(socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        apply_save_action(socket, tag, action)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tag(socket, :new, tag_params, _action) do
    case Mapping.submit_tag(socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tag))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp apply_save_action(socket, tag, "Approve") do
    {:ok, tag} = Mapping.approve_tag(tag)

    {:noreply,
     socket
     |> put_flash(:info, "Tag ##{tag.number} approved")
     |> push_navigate(to: return_path(socket.assigns.return_to, tag))}
  end

  defp apply_save_action(socket, tag, "Delist") do
    {:ok, tag} = Mapping.delist_tag(tag)

    {:noreply,
     socket
     |> put_flash(:info, "Tag ##{tag.number} delisted")
     |> push_navigate(to: return_path(socket.assigns.return_to, tag))}
  end

  defp apply_save_action(socket, tag, "Save") do
    {:noreply,
     socket
     |> put_flash(:info, "Tag saved as draft")
     |> push_navigate(to: return_path(socket.assigns.return_to, tag))}
  end

  defp return_path("index", _tag), do: ~p"/admin/tags"
  defp return_path("edit", tag), do: ~p"/admin/tags/#{tag}/edit"
end
