defmodule Herald.NATS.MixProject do
  use Mix.Project

  def project do
    [
      app: :herald_nats,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

# Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Herald
      {:herald, "~> 0.1"},

      # Client
      {:gnat, "~> 1.0.1"},

      # Encoder/Decoder
      {:jason, "~> 1.2"},

      # Documentation
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},

      # TDD
      {:mix_test_watch, "~> 1.0", only: :test}
    ]
  end
end
