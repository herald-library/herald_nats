use Mix.Config

config :herald, 
  router: MyApp.Router,
  nats_url: "http://127.0.0.1:4222?connection_timeout=30000"
