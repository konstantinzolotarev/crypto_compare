defmodule CryptoCompare.Mixfile do
  use Mix.Project

  @description """
    CryptoCompare Elixir API client
  """

  def project do
    [
      app: :crypto_compare,
      version: "0.1.0",
      elixir: "~> 1.3",
      name: "CryptoCompare",
      description: @description,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      source_url: "https://github.com/konstantinzolotarev/crypto_compare"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"}
    ]
  end

  defp package do
   [ maintainers: ["Konstantin Zolotarev"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/konstantinzolotarev/crypto_compare"} ]
  end
end
