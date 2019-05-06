defmodule CryptoCompare.Mixfile do
  use Mix.Project

  @description """
    CryptoCompare Elixir API client
  """

  def project do
    [
      app: :crypto_compare,
      version: "0.1.1",
      elixir: "~> 1.3",
      name: "CryptoCompare",
      description: @description,
      docs: [extras: ["README.md"]],
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
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
   [ maintainers: ["Konstantin Zolotarev"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/konstantinzolotarev/crypto_compare"} ]
  end
end
