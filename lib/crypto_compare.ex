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
  
  @spec price(String.t, [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms, params) when is_list(tsyms), do: price(fsym, Enum.join(tsyms, ","), params)

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

  def pricemulti(fsyms, tsyms, params) when is_list(fsyms), do: pricemulti(Enum.join(fsyms, ","), tsyms, params)

  def pricemulti(fsyms, tsyms, params) when is_list(tsyms), do: pricemulti(fsyms, Enum.join(tsyms, ","), params)
 
  def pricemulti(fsyms, tsyms, params), do: ApiMini.get_body("pricemulti", [fsyms: fsyms, tsyms: tsyms] ++ params)


  @doc """
  Get all the current trading info (price, vol, open, high, low etc) of any list of cryptocurrencies
  in any other currency that you need.If the crypto does not trade directly into the toSymbol requested, 
  BTC will be used for conversion. This API also returns Display values for all the fields. 
  If the opposite pair trades we invert it (eg.: BTC-XMR).

  Optional parameters: 
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  Example: 

  ```elixir
  iex(16)> CryptoCompare.pricemultifull(["ETH", "DASH"], ["BTC", "USD"], [extraParams: "my app"])
  {:ok,
  %{DISPLAY: %{DASH: %{BTC: %{CHANGE24HOUR: "Ƀ 0.00083",
         CHANGEPCT24HOUR: "1.01", FROMSYMBOL: "DASH", HIGH24HOUR: "Ƀ 0.08821",
         LASTMARKET: "Kraken", LASTTRADEID: 1505742927.3238,
         LASTUPDATE: "Just now", LASTVOLUME: "DASH 1",
         LASTVOLUMETO: "Ƀ 0.08374", LOW24HOUR: "Ƀ 0.08130",
         MARKET: "CryptoCompare Index", MKTCAP: "Ƀ 628.13 K",
         OPEN24HOUR: "Ƀ 0.08218", PRICE: "Ƀ 0.08301",
         SUPPLY: "DASH 7,566,875.1", TOSYMBOL: "Ƀ",
         VOLUME24HOUR: "DASH 66,103.7", VOLUME24HOURTO: "Ƀ 5,598.87"},
       USD: %{CHANGE24HOUR: "$ 36.1", CHANGEPCT24HOUR: "11.99",
         FROMSYMBOL: "DASH", HIGH24HOUR: "$ 340.91", LASTMARKET: "HitBTC",
         LASTTRADEID: 34140863, LASTUPDATE: "Just now",
         LASTVOLUME: "DASH 0.05400", LASTVOLUMETO: "$ 18.16",
         LOW24HOUR: "$ 296.75", MARKET: "CryptoCompare Index",
         MKTCAP: "$ 2,551.47 M", OPEN24HOUR: "$ 301.09", PRICE: "$ 337.19",
         SUPPLY: "DASH 7,566,875.1", TOSYMBOL: "$",
         VOLUME24HOUR: "DASH 33,876.6", VOLUME24HOURTO: "$ 10,855,035"}},
     ETH: %{BTC: %{CHANGE24HOUR: "Ƀ 0.0041", CHANGEPCT24HOUR: "5.93",
         FROMSYMBOL: "Ξ", HIGH24HOUR: "Ƀ 0.07573", LASTMARKET: "Poloniex",
         LASTTRADEID: 34391845, LASTUPDATE: "Just now", LASTVOLUME: "Ξ 3",
         LASTVOLUMETO: "Ƀ 0.2188", LOW24HOUR: "Ƀ 0.06866",
         MARKET: "CryptoCompare Index", MKTCAP: "Ƀ 6,903.97 K",
         OPEN24HOUR: "Ƀ 0.06883", PRICE: "Ƀ 0.07291",
         SUPPLY: "Ξ 94,691,674.1", TOSYMBOL: "Ƀ",
         VOLUME24HOUR: "Ξ 440,392.5", VOLUME24HOURTO: "Ƀ 31,872.6"},
       USD: %{CHANGE24HOUR: "$ 43.02", CHANGEPCT24HOUR: "16.97",
         FROMSYMBOL: "Ξ", HIGH24HOUR: "$ 301.17", LASTMARKET: "Gemini",
         LASTTRADEID: 1729460950, LASTUPDATE: "Just now", LASTVOLUME: "Ξ 1.7",
         LASTVOLUMETO: "$ 504.56", LOW24HOUR: "$ 251.78",
         MARKET: "CryptoCompare Index", MKTCAP: "$ 28.08 B",
         OPEN24HOUR: "$ 253.55", PRICE: "$ 296.57", SUPPLY: "Ξ 94,691,674.1",
         TOSYMBOL: "$", VOLUME24HOUR: "Ξ 1,000,576.4",
         VOLUME24HOURTO: "$ 279,431,015.1"}}},
   RAW: %{DASH: %{BTC: %{CHANGE24HOUR: 8.299999999999974e-4,
         CHANGEPCT24HOUR: 1.0099780968605467, FLAGS: "4", FROMSYMBOL: "DASH",
         HIGH24HOUR: 0.08821, LASTMARKET: "Kraken",
         LASTTRADEID: 1505742927.3238, LASTUPDATE: 1505742927,
         LASTVOLUME: 1.00468613, LASTVOLUMETO: 0.0837405889355,
         LOW24HOUR: 0.0813, MARKET: "CCCAGG", MKTCAP: 628126.2997194666,
         OPEN24HOUR: 0.08218, PRICE: 0.08301, SUPPLY: 7566875.07191262,
         TOSYMBOL: "BTC", TYPE: "5", VOLUME24HOUR: 66103.69737247002,
         VOLUME24HOURTO: 5598.867303056865},
       USD: %{CHANGE24HOUR: 36.10000000000002,
         CHANGEPCT24HOUR: 11.989770500514805, FLAGS: "2", FROMSYMBOL: "DASH",
         HIGH24HOUR: 340.91, LASTMARKET: "HitBTC", LASTTRADEID: 34140863,
         LASTUPDATE: 1505742916, LASTVOLUME: 0.054, LASTVOLUMETO: 18.15534,
         LOW24HOUR: 296.75, MARKET: "CCCAGG", MKTCAP: 2551474605.4982166,
         OPEN24HOUR: 301.09, PRICE: 337.19, SUPPLY: 7566875.07191262,
         TOSYMBOL: "USD", TYPE: "5", VOLUME24HOUR: 33876.57931777,
         VOLUME24HOURTO: 10855035.024934988}},
     ETH: %{BTC: %{CHANGE24HOUR: 0.00408, CHANGEPCT24HOUR: 5.927647827981985,
         FLAGS: "4", FROMSYMBOL: "ETH", HIGH24HOUR: 0.07573,
         LASTMARKET: "Poloniex", LASTTRADEID: 34391845, LASTUPDATE: 1505742928,
         LASTVOLUME: 3.00073068, LASTVOLUMETO: 0.21879227, LOW24HOUR: 0.06866,
         MARKET: "CCCAGG", MKTCAP: 6903969.958106048, OPEN24HOUR: 0.06883,
         PRICE: 0.07291, SUPPLY: 94691674.0928, TOSYMBOL: "BTC", TYPE: "5",
         VOLUME24HOUR: 440392.4897805099, VOLUME24HOURTO: 31872.558630222768},
       USD: %{CHANGE24HOUR: 43.01999999999998,
         CHANGEPCT24HOUR: 16.967067639518824, FLAGS: "4", FROMSYMBOL: "ETH",
         HIGH24HOUR: 301.17, LASTMARKET: "Gemini", LASTTRADEID: 1729460950,
         LASTUPDATE: 1505742937, LASTVOLUME: 1.7, LASTVOLUMETO: 504.56,
         LOW24HOUR: 251.78, MARKET: "CCCAGG", MKTCAP: 28082709785.7017,
         OPEN24HOUR: 253.55, PRICE: 296.57, SUPPLY: 94691674.0928,
         TOSYMBOL: "USD", TYPE: "5", VOLUME24HOUR: 1000576.356339929,
         VOLUME24HOURTO: 279431015.074645}}}}}
  ```
  """
  @spec pricemultifull(String.t | [String.t], String.t | [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def pricemultifull(fsyms, tsyms, params \\ [])

  def pricemultifull(fsyms, tsyms, params) when is_list(fsyms), do: pricemultifull(Enum.join(fsyms, ","), tsyms, params)

  def pricemultifull(fsyms, tsyms, params) when is_list(tsyms), do: pricemultifull(fsyms, Enum.join(tsyms, ","), params)

  def pricemultifull(fsyms, tsyms, params), do: ApiMini.get_body("pricemultifull", [fsyms: fsyms, tsyms: tsyms] ++ params)


  @doc """
  Compute the current trading info (price, vol, open, high, low etc) of the requested pair as a volume weighted average based on the markets requested.

  Optional parameters:
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  Example: 

  ```elixir
  iex(2)> CryptoCompare.generate_avg("BTC", "USD", ["Coinbase", "Bitfinex"])
  {:ok,
    %{
      DISPLAY: %{CHANGE24HOUR: "$ 425", CHANGEPCT24HOUR: "11.53", FROMSYMBOL: "Ƀ",
        HIGH24HOUR: "$ 4,130", LASTMARKET: "Coinbase", LASTTRADEID: 21066901,
        LASTUPDATE: "Just now", LASTVOLUME: "Ƀ 3.16", LASTVOLUMETO: "$ 12,981.3",
        LOW24HOUR: "$ 3,678", MARKET: "CUSTOMAGG", OPEN24HOUR: "$ 3,685",
        PRICE: "$ 4,110", TOSYMBOL: "$", VOLUME24HOUR: "Ƀ 14,474.5",
        VOLUME24HOURTO: "$ 56,142,934.5"},
      RAW: %{CHANGE24HOUR: 425, CHANGEPCT24HOUR: 11.533242876526458, FLAGS: 0,
        FROMSYMBOL: "BTC", HIGH24HOUR: 4130, LASTMARKET: "Coinbase",
        LASTTRADEID: 21066901, LASTUPDATE: 1505744225, LASTVOLUME: 3.15847893,
        LASTVOLUMETO: 12981.348402299998, LOW24HOUR: 3678, MARKET: "CUSTOMAGG",
        OPEN24HOUR: 3685, PRICE: 4110, TOSYMBOL: "USD",
        VOLUME24HOUR: 14474.464341350002, VOLUME24HOURTO: 56142934.480225}
    }
  }
  ```
  """
  @spec generate_avg(String.t, String.t, String.t | [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def generate_avg(fsym, tsym, markets, params \\ [])

  def generate_avg(fsym, tsym, markets, params) when is_list(markets), do: generate_avg(fsym, tsym, Enum.join(markets, ","), params)

  def generate_avg(fsym, tsym, markets, params), do: ApiMini.get_body("generateAvg", [fsym: fsym, tsym: tsym, markets: markets] ++ params)


  @doc """
  Get day average price. 
  The values are based on hourly vwap data and the average can be calculated in different waysIt uses BTC conversion 
  if data is not available because the coin is not trading in the specified currency. 
  If tryConversion is set to false it will give you the direct data. If no toTS is given it will automatically do the current day. 
  Also for different timezones use the UTCHourDiff paramThe calculation types are: 
  HourVWAP - a VWAP of the hourly close price,
  MidHighLow - the average between the 24 H high and low.
  VolFVolT - the total volume from / the total volume to (only avilable with tryConversion set to false so only for direct trades but the value should be the most accurate price)

  Optional parameters: 
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
   - `avgType` - String. Default: `HourVWAP`
   - `UTCHourDiff` - int. Default: `0`
   - `toTs` - timestamp. Hour unit

   ## Example

   ```elixir

   ```
  """
  @spec day_avg(String.t, String.t, [tuple]) :: {:ok, map} | {:error, any}
  def day_avg(fsym, tsym, params \\ []), do: ApiMini.get_body("dayAvg", [fsym: fsym, tsym: tsym] ++ params)

  
  @doc """
  Get the price of any cryptocurrency in any other currency that you need at a given timestamp.
  The price comes from the daily info - so it would be the price at the end of the day GMT based on the requested TS. 
  If the crypto does not trade directly into the toSymbol requested, BTC will be used for conversion. 
  Tries to get direct trading pair data, if there is none or it is more than 30 days before the ts requested, it uses BTC conversion. 
  If the opposite pair trades we invert it (eg.: BTC-XMR)

  Optional parameters: 
   - `ts` - Timestamp. 
   - `markets` - String. Name of exchanges, include multiple Default: `CCAGG`
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
    
  ## Example:

  ```elixir
  iex(3)> CryptoCompare.price_historical("ETH", ["BTC"])
  {:ok, %{ETH: %{BTC: 0.0725}}}
  ```
  """
  @spec price_historical(String.t, String.t | [String.t], [tuple]) :: {:ok, map} | {:error, any}
  def price_historical(fsym, tsyms, params \\ [])
  def price_historical(fsym, tsyms, params) when is_list(tsyms), do: price_historical(fsym, Enum.join(tsyms, ","), params)
  def price_historical(fsym, tsyms, params), do: ApiMini.get_body("pricehistorical", [fsym: fsym, tsyms: tsyms] ++ params)


end
