# CryptoCompare Elixir API [![Hex pm](http://img.shields.io/hexpm/v/crypto_compare.svg?style=flat)](https://hex.pm/packages/crypto_compare) [![hex.pm downloads](https://img.shields.io/hexpm/dt/crypto_compare.svg?style=flat)](https://hex.pm/packages/crypto_compare)

CryptoCompare website API for Elixir.

[Documentation](https://hexdocs.pm/crypto_compare/api-reference.html) available on hex.pm

## Installation

First add `crypto_compare` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:crypto_compare, "~> 0.1.0"}
  ]
end
```

Then run `$ mix deps.get`.

For Elixir below version `1.3` add `:crypto_compare` to your applications list.

```elixir
def application do
  [applications: [:crypto_compare]]
end
```

## Configuration

There are no lot of configuration options. For now only `request_timeout` option is available.
It will set default timeout for reply from CryptoCompare API. By default it set to `8` seconds

You could change it using your application `config.exs`:

```elixir
use Mix.Config

config :crypto_compare, request_timeout: 10_000
```

## Usage

API is fully public so you don't need any special configs and could be used out of the box.

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

## License

```
Copyright © 2017 Konstantin Zolotarev

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.
```
