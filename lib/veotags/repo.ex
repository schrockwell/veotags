defmodule Veotags.Repo do
  use Ecto.Repo,
    otp_app: :veotags,
    adapter: Ecto.Adapters.Postgres
end
