import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :holidays, HolidaysWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nIVW0HuC60qWaStcGNil4dDH0tGtNbei8UWjVvU663TXXsyU1FOg2N10tc/IHc0N",
  server: false

# In test we don't send emails.
config :holidays, Holidays.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :holidays, :store_impl, StoreMock

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
