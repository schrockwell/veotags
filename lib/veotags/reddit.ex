defmodule Veotags.Reddit do
  def fetch_latest(opts \\ []) do
    after_param = Keyword.get(opts, :after, nil)

    resp = Req.get!("https://api.reddit.com/r/veotags/new/?after=#{after_param}")

    case resp.body do
      %{"data" => %{"after" => after_name, "children" => children}} ->
        posts =
          children
          |> Enum.map(&parse_image_link/1)
          |> Enum.reject(&is_nil/1)

        {:ok, posts, after_name}

      _ ->
        :error
    end
  end

  defp parse_image_link(%{"kind" => "t3", "data" => %{"post_hint" => "image"} = data}) do
    %{
      accuracy: "unknown",
      comment: data["title"],
      photo: data["url_overridden_by_dest"],
      reddit_name: data["name"],
      reporter: "u/" <> data["author"],
      source_url: "https://reddit.com" <> data["permalink"],
      submitted_at: DateTime.from_unix!(trunc(data["created_utc"]), :second)
    }
  end

  defp parse_image_link(_), do: nil
end
