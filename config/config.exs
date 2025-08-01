# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :veotags,
  ecto_repos: [Veotags.Repo],
  generators: [timestamp_type: :utc_datetime]

config :veotags, Veotags.Scheduler,
  jobs: [
    {"@daily", {Veotags.Mapping, :delete_abandoned_submissions, []}}
  ]

# Configures the endpoint
config :veotags, VeotagsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: VeotagsWeb.ErrorHTML, json: VeotagsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Veotags.PubSub,
  live_view: [signing_salt: "jAihSf0b"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :veotags, Veotags.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  veotags: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  veotags: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :waffle,
  storage: Waffle.Storage.S3,
  bucket: {:system, "S3_BUCKET"},
  asset_host: {:system, "S3_ASSET_HOST"}

config :ex_aws,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :ex_aws, :s3,
  host: {:system, "AWS_HOST"},
  region: {:system, "AWS_REGION"},
  scheme: "https://"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
