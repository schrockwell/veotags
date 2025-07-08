defmodule Veotags.Photo do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :px2000, :px500]

  # make all uploads public (https://hexdocs.pm/waffle/Waffle.Storage.S3.html#module-access-control-permissions)
  def acl(:original, _), do: :private
  def acl(:px2000, _), do: :public_read
  def acl(:px500, _), do: :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # def bucket({_file, scope}) do
  #   scope.bucket || bucket()
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(allowed_extensions(), file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def allowed_extensions do
    ~w(.jpg .jpeg .png)
  end

  @seven_days 60 * 60 * 24 * 7

  def presigned_url(photo) do
    bucket = System.fetch_env!("S3_BUCKET")

    :s3
    |> ExAws.Config.new([])
    |> ExAws.S3.presigned_url(:get, bucket, Path.join("uploads", photo.file_name),
      expires_in: @seven_days
    )
    |> case do
      {:ok, url} ->
        expires_at =
          DateTime.utc_now() |> DateTime.add(@seven_days, :second) |> DateTime.truncate(:second)

        {:ok, url, expires_at}

      _ ->
        :error
    end
  end

  # Define a thumbnail transformation:
  def transform(:px2000, _) do
    {:convert, "-resize 2000x2000^ -format jpeg", :jpg}
  end

  def transform(:px500, _) do
    {:convert, "-resize 500x500^ -sharpen 0x1 -format jpeg", :jpg}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/tags/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end
end
