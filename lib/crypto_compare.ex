defmodule CryptoCompare do

  @moduledoc """
  Provides a basic HTTP interface to allow easy communication with the CryptoCompare API, by wrapping `HTTPoison`

  Example: 

  ```elixir
  iex(1)> CryptoCompare.coin_list
  {:ok,
    %{DCT: %{Algorithm: "N/A", CoinName: "Decent", FullName: "Decent (DCT)",
      FullyPremined: "0", Id: "25721", ImageUrl: "/media/351389/dct.png",
      Name: "DCT", PreMinedValue: "N/A", ProofType: "PoS", SortOrder: "702",
      TotalCoinSupply: "73197775", TotalCoinsFreeFloat: "N/A",
      Url: "/coins/dct/overview"},
      PX: %{Algorithm: "SHA256", CoinName: "PXcoin", FullName: "PXcoin (PX)", ...},
      "STR*": %{Algorithm: "Scrypt", CoinName: "StarCoin", ...},
      BSTK: %{Algorithm: "PoS", ...}, SUR: %{...}, ...}}
  ```

  """
  alias CryptoCompare.Util.{Api, ApiMini}

  @doc """
  Get general info for all the coins available on the website.

  Example: 

  ```elixir
  iex(1)> CryptoCompare.coin_list
  {:ok,
    %{DCT: %{Algorithm: "N/A", CoinName: "Decent", FullName: "Decent (DCT)",
      FullyPremined: "0", Id: "25721", ImageUrl: "/media/351389/dct.png",
      Name: "DCT", PreMinedValue: "N/A", ProofType: "PoS", SortOrder: "702",
      TotalCoinSupply: "73197775", TotalCoinsFreeFloat: "N/A",
      Url: "/coins/dct/overview"},
      PX: %{Algorithm: "SHA256", CoinName: "PXcoin", FullName: "PXcoin (PX)", ...},
      "STR*": %{Algorithm: "Scrypt", CoinName: "StarCoin", ...},
      BSTK: %{Algorithm: "PoS", ...}, SUR: %{...}, ...}}
  ```
  """

  @spec coin_list() :: {:ok, map} | {:error, any}
  def coin_list, do: Api.get_body("coinlist")

  @doc """
  Get the latest price for a list of one or more currencies. Really fast, 20-60 ms. Cached each 10 seconds.

  Example: 
  
  ```elixir
  iex(1)> CryptoCompare.price("ETH", "BTC")
  {:ok, %{BTC: 0.07356}}
  ```
  """
  @spec price(String.t, [String.t]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms) when is_list(tsyms), do: price(fsym, Enum.join(tsyms, ","))

  @doc """
  Get the latest price for a list of one or more currencies. Really fast, 20-60 ms. Cached each 10 seconds.
  
  This function also accept additional parameters: 
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
  
  Example: 

  ```elixir
  iex(1)> CryptoCompare.price("ETH", ["BTC", "LTC"])
  {:ok, %{BTC: 0.07357, LTC: 5.3}}
  ```

  With specified exchange: 

  ```elixir
  iex(1)> CryptoCompare.price("ETH", ["USD", "EUR"], [e: "Coinbase"])
  {:ok, %{EUR: 254, USD: 301.91}}
  ```

  ```elixir
  iex(17)> CryptoCompare.price("ETH", ["BTC", "LTC"], [extraParams: "my super app"])
  {:ok, %{BTC: 0.07327, LTC: 5.25}}
  ```
  """
  @spec price(String.t, String.t | [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms, params \\ [])
  
  @doc false
  @spec price(String.t, [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms, params) when is_list(tsyms), do: price(fsym, Enum.join(tsyms, ","), params)

  @doc false
  @spec price(String.t, String.t, [tuple]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms, params), do: ApiMini.get_body("price", [fsym: fsym, tsyms: tsyms] ++ params)


  @doc """
  Get a matrix of currency prices. For several symbols.

  Optional parameters: 
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  Example: 

  ```elixir
  iex(1)> CryptoCompare.pricemulti(["ETH", "DASH"], ["BTC", "USD"])
  {:ok, %{DASH: %{BTC: 0.08289, USD: 337.4}, ETH: %{BTC: 0.07306, USD: 297.98}}}
  ```
  """
  @spec pricemulti(String.t | [String.t], String.t | [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def pricemulti(fsyms, tsyms, params \\ [])

  @doc false
  def pricemulti(fsyms, tsyms, params) when is_list(fsyms), do: pricemulti(Enum.join(fsyms, ","), tsyms, params)

  @doc false
  def pricemulti(fsyms, tsyms, params) when is_list(tsyms), do: pricemulti(fsyms, Enum.join(tsyms, ","), params)
 
  @doc false
  def pricemulti(fsyms, tsyms, params), do: ApiMini.get_body("pricemulti", [fsyms: fsyms, tsyms: tsyms] ++ params)
end
