defmodule Veotags.Photo do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]

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

  def presigned_url(photo) do
    bucket = System.fetch_env!("S3_BUCKET")

    :s3
    |> ExAws.Config.new([])
    |> ExAws.S3.presigned_url(:get, bucket, Path.join("uploads", photo.file_name), [])
    |> case do
      {:ok, url} -> url
      _ -> "/images/placeholder.png"
    end
  end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end

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
