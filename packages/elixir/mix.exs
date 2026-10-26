defmodule VeroTestFixtures.MixProject do
  use Mix.Project

  def project do
    [
      app: :vero_test_fixtures,
      version: "0.1.0",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:phoenix, "== 1.7.0"}
    ]
  end
end
