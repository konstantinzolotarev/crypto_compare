defmodule CryptoCompare do

  @moduledoc """
  Provides a basic HTTP interface to allow easy communication with the CryptoCompare API, by wrapping `HTTPoison`

  ** For now only HTTP REST API is available**.
  Work on Websocket one is in progress.

  [API Documentation](https://www.cryptocompare.com/api/#-api-data-)

  ## Example:

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

  ## Example:

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

  ## Example:

  ```elixir
  iex(1)> CryptoCompare.price("ETH", "BTC")
  {:ok, %{BTC: 0.07356}}
  ```
  """
  @spec price(String.t, String.t | [String.t]) :: {:ok, map} | {:error, any}
  def price(fsym, tsyms) when is_list(tsyms), do: price(fsym, Enum.join(tsyms, ","))

  @doc """
  Get the latest price for a list of one or more currencies. Really fast, 20-60 ms. Cached each 10 seconds.

  **Optional parameters:**
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  ## Example:

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
  def price(fsym, tsyms, params) when is_list(tsyms), do: price(fsym, Enum.join(tsyms, ","), params)
  def price(fsym, tsyms, params), do: ApiMini.get_body("price", [fsym: fsym, tsyms: tsyms] ++ params)


  @doc """
  Get a matrix of currency prices. For several symbols.

  **Optional parameters:**
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  ## Example:

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

  **Optional parameters:**
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  ## Example:

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

  **Optional parameters:**
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`

  ## Example:

  ```elixir
  iex(1)> CryptoCompare.generate_avg("BTC", "USD", ["Coinbase", "Bitfinex"])
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

  **Optional parameters:**
   - `e` - String. Name of exchange. Default: CCCAGG
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
   - `avgType` - String. Default: `HourVWAP`
   - `UTCHourDiff` - int. Default: `0`
   - `toTs` - timestamp. Hour unit

  ## Example

  ```elixir
  iex(1)> CryptoCompare.day_avg("BTC", "ETH")
  {:ok, %{ConversionType: %{conversionSymbol: "", type: "invert"}, ETH: 13.66}}
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

  **Optional parameters:**
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


  @doc """
  Get data for a currency pair.
  It returns general block explorer information, aggregated data and individual data for each exchange available.

  This api is getting abused and will be moved to a min-api path in the near future. Please try not to use it.

  ## Example:
  ```elixir
  iex(2)> CryptoCompare.coin_snapshot("BTC", "USD")
  {:ok,
    %{AggregatedData: %{FLAGS: "4", FROMSYMBOL: "BTC", HIGH24HOUR: "4051.38",
      LASTMARKET: "Coinbase", LASTTRADEID: "21143529", LASTUPDATE: "1505915744",
      LASTVOLUME: "0.00025062", LASTVOLUMETO: "0.9974676", LOW24HOUR: "3839.51",
      MARKET: "CCCAGG", OPEN24HOUR: "3961.07", PRICE: "3980.47", TOSYMBOL: "USD",
      TYPE: "5", VOLUME24HOUR: "92013.70078287183",
      VOLUME24HOURTO: "362226520.4356543"}, Algorithm: "SHA256",
      BlockNumber: 486154, BlockReward: 12.5,
      Exchanges: [
        %{FLAGS: "4", FROMSYMBOL: "BTC", HIGH24HOUR: "4049",
          LASTTRADEID: "21143529", LASTUPDATE: "1505915744",
          LASTVOLUME: "0.00025062", LASTVOLUMETO: "0.9974676", LOW24HOUR: "3850.01",
          MARKET: "Coinbase", OPEN24HOUR: "3960.09", PRICE: "3980", TOSYMBOL: "USD",
          TYPE: "2", VOLUME24HOUR: "10388.061612519965",
          VOLUME24HOURTO: "40860804.10243919"},
        %{FLAGS: "4", FROMSYMBOL: "BTC", HIGH24HOUR: "4190", LASTTRADEID: "3274802",
          LASTUPDATE: "1505915715", LASTVOLUME: "0.05115365",
          LASTVOLUMETO: "209.72996500000002", LOW24HOUR: "4005", MARKET: "Cexio",
          OPEN24HOUR: "4115.2", ...}
      ], NetHashesPerSecond: 7898572058.405353,
      ProofType: "PoW", TotalCoinsMined: 1.65769e7}}
  ```
  """
  @spec coin_snapshot(String.t, String.t) :: {:ok, map} | {:error, any}
  def coin_snapshot(fsym, tsym), do: Api.get_body("coinsnapshot", [fsym: fsym, tsym: tsym])

  @doc """
  Get the general, subs (used to connect to the streamer and to figure
  out what exchanges we have data for and what are the exact coin pairs of the coin)
  and the aggregated prices for all pairs available.

  ## Example:

  ```elixir
  iex(4)> CryptoCompare.coin_snapshot_full_by_id(1182)
  {:ok,
    %{General: %{AffiliateUrl: "https://bitcoin.org/en/", Algorithm: "SHA256",
      BaseAngularUrl: "/coins/btc/", BlockNumber: 486154, BlockReward: 12.5,
      BlockRewardReduction: "50%", BlockTime: 600, DangerTop: "",
      Description: "something", DifficultyAdjustment: "2016 blocks", DocumentType: "Webpagecoinp",
      Features: "something", H1Text: "Bitcoin (BTC)", Id: "1182", ImageUrl: "/media/19633/btc.png",
      InfoTop: "", LastBlockExplorerUpdateTS: 1505915570, Name: "Bitcoin",
      NetHashesPerSecond: 7898572058.405353, PreviousTotalCoinsMined: 0.0,
      ProofType: "PoW",
      Sponsor: %{ImageUrl: "/media/11417633/utrust_sponsor.png",
        Link: "https://utrust.io", TextTop: "Sponsored by"},
      StartDate: "03/01/2009", Symbol: "BTC",
      Technology: "something", TotalCoinSupply: "21000000", TotalCoinsMined: 1.65769e7,
      Twitter: "@bitcoin", Url: "/coins/btc/", WarningTop: "",
      Website: "<a href='https://bitcoin.org/en/' target='_blank'>Bitcoin</a>"},
      ICO: %{Status: "N/A", WhitePaper: "-"},
      SEO: %{BaseImageUrl: "https://www.cryptocompare.com",
        BaseUrl: "https://www.cryptocompare.com", OgImageHeight: "300",
        OgImageUrl: "/media/19633/btc.png", OgImageWidth: "300",
        PageDescription: "Live Bitcoin prices from all markets and BTC coin market Capitalization. Stay up to date with the latest Bitcoin price movements and forum discussion. Check out our snapshot charts and see when there is an opportunity to buy or sell Bitcoin.",
                                                                                                                        PageTitle: "Bitcoin (BTC) - Live Bitcoin price and market cap"},
        StreamerDataRaw: [...],
        Subs: ["2~BTCE~BTC~CNH", "2~LocalBitcoins~BTC~GEL", ...]}}
  ```
  """
  @spec coin_snapshot_full_by_id(integer | String.t) :: {:ok, map} | {:error, any}
  def coin_snapshot_full_by_id(id), do: Api.get_body("coinsnapshotfullbyid", [id: id])

  @doc """
  Used to get all the mining equipment available on the website. It returns an array of mining equipment objects

  ## Example:

  ```elixir
  iex(1)> CryptoCompare.mining_equipment
  {:ok,
    %{CoinData: %{BTC: %{BlockNumber: 486156, BlockReward: 12.5,
      BlockRewardReduction: "50%", BlockTime: 600,
      DifficultyAdjustment: "2016 blocks",
      NetHashesPerSecond: 7898572058.405353, PreviousTotalCoinsMined: 0.0,
      PriceUSD: 4034.81, Symbol: "BTC", TotalCoinsMined: 16576950.0},
      DASH: %{BlockNumber: 740410, BlockReward: 3.6029519103467464,
        BlockRewardReduction: "50%", BlockTime: 37, DifficultyAdjustment: "DGW",
        NetHashesPerSecond: 229045990915876.0,
        PreviousTotalCoinsMined: 7570895.96624418, PriceUSD: 342.84,
        Symbol: "DASH", TotalCoinsMined: 7570899.56919609},
      Message: "Mining contracts data successfully returned",
      MiningData: %{"35580": %{AffiliateURL: "https://mineshop.eu/monero-xmr-miners/monero-miner-gpu-mining-detail",
        Algorithm: "CryptoNight", Company: "MineShop", Cost: "2142.90",
        CurrenciesAvailable: "XMR",
        CurrenciesAvailableLogo: "/media/19969/xmr.png",
        CurrenciesAvailableName: "Monero", Currency: "USD", EquipmentType: "Rig",
        HashesPerSecond: "3200", Id: "35580",
        LogoUrl: "/media/352238/eth_rig_125.png",
        Name: "Monero Mining Rig 3200 H/s", ParentId: "35553",
        PowerConsumption: "800", Recommended: false, Sponsored: false,
        Url: "/mining/mineshop/monero-mining-rig-3200hs/"},
        "2476": %{...}, ...}, Response: "Success", Type: 100}}
  ```
  """
  @spec mining_equipment() :: {:ok, map} | {:error, any}
  def mining_equipment, do: Api.get_body("miningequipment")

  @doc """
  Returns all the mining contracts in a JSON array.

  ## Example:

  ```elixir
  iex(3)> CryptoCompare.mining_contracts
  {:ok,
    %{CoinData: %{BCH: %{BlockNumber: 0, BlockReward: 0.0,
      BlockRewardReduction: nil, BlockTime: 600, DifficultyAdjustment: nil,
      NetHashesPerSecond: 0.0, PreviousTotalCoinsMined: 0.0, PriceUSD: 507.16,
      Symbol: "BCH", TotalCoinsMined: 16598463.0},
      BTC: %{BlockNumber: 486156, BlockReward: 12.5, BlockRewardReduction: "50%",
        BlockTime: 600, DifficultyAdjustment: "2016 blocks",
        NetHashesPerSecond: 7898572058.405353, PreviousTotalCoinsMined: 0.0,
        PriceUSD: 4036.23, Symbol: "BTC", TotalCoinsMined: 16576950.0},
      DASH: %{BlockNumber: 740410, BlockReward: 3.6029519103467464,
        BlockRewardReduction: "50%", BlockTime: 37, DifficultyAdjustment: "DGW",
        NetHashesPerSecond: 229045990915876.0,
        PreviousTotalCoinsMined: 7570895.96624418, PriceUSD: 342.99,
        Symbol: "DASH", TotalCoinsMined: 7570899.56919609},
      ETH: %{BlockNumber: 4294988, BlockReward: 5.0, BlockRewardReduction: "",
        BlockTime: 19, DifficultyAdjustment: "Per 1 Block",
        NetHashesPerSecond: 104406325175528.05, PreviousTotalCoinsMined: 0.0,
        PriceUSD: 292.86, Symbol: "ETH", TotalCoinsMined: 94731137.8428},
      LTC: %{BlockNumber: 1280725, BlockReward: 25.0,
        BlockRewardReduction: "50%", BlockTime: 150,
        DifficultyAdjustment: "2016 blocks",
        NetHashesPerSecond: 23936316649465.7,
        PreviousTotalCoinsMined: 53016132.3718871, PriceUSD: 54.13,
        Symbol: "LTC", TotalCoinsMined: 53016232.37188706},
      XMR: %{BlockNumber: 1402642, BlockReward: 6.819603784146,
        BlockRewardReduction: "-", BlockTime: 120,
        DifficultyAdjustment: "2 blocks", NetHashesPerSecond: 241354987.75833,
        PreviousTotalCoinsMined: 0.0, PriceUSD: 97.87, Symbol: "XMR",
        TotalCoinsMined: 15104905.567139952},
      ZEC: %{BlockNumber: 187966, BlockReward: 10.0, BlockRewardReduction: nil,
        BlockTime: 150, DifficultyAdjustment: nil,
        NetHashesPerSecond: 283238210.0, PreviousTotalCoinsMined: 0.0,
        PriceUSD: 193.75, Symbol: "ZEC", TotalCoinsMined: 2224581.25}},
        Message: "Mining contracts data successfully returned",
        MiningData: %{"25743": %{AffiliateURL: "http://bit.ly/2tudp6y",
          Algorithm: "X11", Company: "HashCoins", ContractLength: "360",
          Cost: "32", CurrenciesAvailable: "DASH",
          CurrenciesAvailableLogo: "/media/20626/dash.png",
          CurrenciesAvailableName: "DigitalCash", Currency: "USD",
          FeePercentage: "0", FeeValue: "0", FeeValueCurrency: "USD",
          HashesPerSecond: "10000000", Id: "25743",
          LogoUrl: "/media/350644/hashflare.png",
          Name: "Mining Contract Dash Small", ParentId: "2363", Recommended: false,
          Sponsored: false, Url: "/mining/hashcoins/mining-contract-x11-small/"},
          "25745": %{AffiliateURL: "http://bit.ly/2tudp6y", ...}, "15709": %{...},
          ...}, Response: "Success", Type: 100}}
  ```
  """
  @spec mining_contracts() :: {:ok, map} | {:error, any}
  def mining_contracts, do: Api.get_body("miningcontracts")

  @doc """
  Get open, high, low, close, volumefrom and volumeto from the each minute historical data.
  This data is only stored for 7 days, if you need more,use the hourly or daily path.
  It uses BTC conversion if data is not available because the coin is not trading in the specified currency

  **Optional parameters:**
   - `toTs` - Timestamp.
   - `e` - String. Name of exchange. Default: `CCAGG`
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
   - `aggregate` - Integer. Default to `1`
   - `limit` - Integer. Default to `1440`

  ## Example:

  ```elixir
  iex(3)> CryptoCompare.histo_minute("BTC", "ETH", [limit: 3])
  {:ok,
    %{Aggregated: false, ConversionType: %{conversionSymbol: "", type: "invert"},
      Data: [%{close: 13.6, high: 13.59, low: 13.6, open: 13.6, time: 1505984700,
        volumefrom: 7.79, volumeto: 106.01},
             %{close: 13.6, high: 13.59, low: 13.6, open: 13.6, time: 1505984760,
               volumefrom: 7.15, volumeto: 97.24},
             %{close: 13.61, high: 13.6, low: 13.61, open: 13.6, time: 1505984820,
               volumefrom: 18.72, volumeto: 255.08},
             %{close: 13.61, high: 13.61, low: 13.61, open: 13.61, time: 1505984880,
               volumefrom: 6.07, volumeto: 82.56}], FirstValueInArray: true,
      Response: "Success", TimeFrom: 1505984700, TimeTo: 1505984880, Type: 100}}
  ```
  """
  @spec histo_minute(String.t, String.t, [tuple]) :: {:ok, map} | {:error, any}
  def histo_minute(fsym, tsym, params \\ []), do: ApiMini.get_body("histominute", [fsym: fsym, tsym: tsym] ++ params)


  @doc """
  Get open, high, low, close, volumefrom and volumeto from the each hour historical data.
  It uses BTC conversion if data is not available because the coin is not trading in the specified currency.

  **Optional parameters:**
   - `toTs` - Timestamp.
   - `e` - String. Name of exchange. Default: `CCAGG`
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
   - `aggregate` - Integer. Default to `1`
   - `limit` - Integer. Default to `168`

  ## Example:

  ```elixir
  iex(5)> CryptoCompare.histo_hour("BTC", "ETH", [limit: 3])
  {:ok,
    %{Aggregated: false, ConversionType: %{conversionSymbol: "", type: "invert"},
      Data: [%{close: 13.7, high: 13.67, low: 13.72, open: 13.7, time: 1505973600,
        volumefrom: 493.02, volumeto: 6750.16},
             %{close: 13.63, high: 13.63, low: 13.76, open: 13.7, time: 1505977200,
               volumefrom: 951.78, volumeto: 13014.42},
             %{close: 13.6, high: 13.58, low: 13.64, open: 13.63, time: 1505980800,
               volumefrom: 1000.15, volumeto: 13602.59},
             %{close: 13.6, high: 13.59, low: 13.61, open: 13.6, time: 1505984400,
               volumefrom: 171.78, volumeto: 2336}], FirstValueInArray: true,
      Response: "Success", TimeFrom: 1505973600, TimeTo: 1505984400, Type: 100}}
  ```
  """
  @spec histo_hour(String.t, String.t, [tuple]) :: {:ok, map} | {:error, any}
  def histo_hour(fsym, tsym, params \\ []), do: ApiMini.get_body("histohour", [fsym: fsym, tsym: tsym] ++ params)

  @doc """
  Get open, high, low, close, volumefrom and volumeto daily historical data.
  The values are based on 00:00 GMT time.
  It uses BTC conversion if data is not available because the coin is not trading in the specified currency.

  **Optional parameters:**
   - `toTs` - Timestamp.
   - `e` - String. Name of exchange. Default: `CCAGG`
   - `extraParams` - String. Name of your application
   - `sign` - bool. If set to true, the server will sign the requests.
   - `tryConversion` - bool. If set to false, it will try to get values without using any conversion at all. Default: `true`
   - `aggregate` - Integer. Default to `1`
   - `limit` - Integer. Default to `30`
   - `allData` - Boolean. Get all data. Default: `false`

  ## Example:

  ```elixir
  iex(1)> CryptoCompare.histo_day("BTC", "ETH", [limit: 3])
  {:ok,
    %{Aggregated: false, ConversionType: %{conversionSymbol: "", type: "invert"},
      Data: [%{close: 13.74, high: 13.23, low: 14.31, open: 14.31,
        time: 1505692800, volumefrom: 34011.1, volumeto: 465408.96},
             %{close: 13.79, high: 13.67, low: 13.94, open: 13.74, time: 1505779200,
               volumefrom: 21632, volumeto: 298705.56},
             %{close: 13.68, high: 13.67, low: 13.85, open: 13.79, time: 1505865600,
               volumefrom: 16536.62, volumeto: 227858.3},
             %{close: 13.61, high: 13.59, low: 13.76, open: 13.68, time: 1505952000,
               volumefrom: 5880.9, volumeto: 80399.15}], FirstValueInArray: true,
      Response: "Success", TimeFrom: 1505692800, TimeTo: 1505952000, Type: 100}}
  ```
  """
  @spec histo_day(String.t, String.t, [tuple]) :: {:ok, map} | {:error, any}
  def histo_day(fsym, tsym, params \\ []), do: ApiMini.get_body("histoday", [fsym: fsym, tsym: tsym] ++ params)

  @doc """
  Get top pairs by volume for a currency (always uses our aggregated data).
  The number of pairs you get is the minimum of the limit you set (default 5) and the total number of pairs available

  **Optional parameters:**
   - `tsym` - String. To symbol
   - `limit` - Integer. Default to `5`
   - `sign` - Boolean. If set to true, the server will sign the request. Default: `false`

  ## Example:

  ```elixir
  iex(1)> CryptoCompare.top_pairs("BTC")
  {:ok,
    %{Data: [%{exchange: "CCCAGG", fromSymbol: "BTC", toSymbol: "JPY",
      volume24h: 136451.73538353332, volume24hTo: 59735591768.351654},
             %{exchange: "CCCAGG", fromSymbol: "BTC", toSymbol: "USD",
               volume24h: 90057.92590708924, volume24hTo: 353713017.2572782},
             %{exchange: "CCCAGG", fromSymbol: "BTC", toSymbol: "KRW",
               volume24h: 14891.462995631156, volume24hTo: 65391518794.84038},
             %{exchange: "CCCAGG", fromSymbol: "BTC", toSymbol: "CNY",
               volume24h: 13383.281520579989, volume24hTo: 312930536.6705389},
             %{exchange: "CCCAGG", fromSymbol: "BTC", toSymbol: "EUR",
               volume24h: 12987.115042599999, volume24hTo: 43056437.811124615}],
      Response: "Success"}}
  ```
  """
  @spec top_pairs(String.t, [tuple]) :: {:ok, map} | {:error, any}
  def top_pairs(fsym, params \\ []), do: ApiMini.get_body("top/pairs", [fsym: fsym] ++ params)
end
