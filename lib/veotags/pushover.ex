defmodule Veotags.Pushover do
  def send_notification(message, params \\ []) do
    url = "https://api.pushover.net/1/messages.json"

    body =
      Enum.into(params, %{
        token: app_token(),
        user: user_key(),
        message: message
      })

    case Req.post(url, json: body) do
      {:ok, %Req.Response{status: 200}} ->
        :ok

      {:ok, %Req.Response{status: status, body: body}} ->
        IO.warn("Pushover notification failed with status #{status}: #{inspect(body)}")
        {:error, :notification_failed}

      {:error, reason} ->
        IO.warn("Pushover request failed: #{inspect(reason)}")
        {:error, :request_failed}
    end
  end

  defp app_token, do: System.fetch_env!("PUSHOVER_APP_TOKEN")
  defp user_key, do: System.fetch_env!("PUSHOVER_USER_KEY")
end
