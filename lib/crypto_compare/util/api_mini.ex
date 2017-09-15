defmodule CryptoCompare.Util.ApiMini do
  @moduledoc false

  use HTTPoison.Base

  @host "https://min-api.cryptocompare.com/"
  @timeout Application.get_env(:crypto_compare, :request_timeout, 8000)

  def host, do: @host
  def process_url(url), do: @host <> url

  defp process_request_options([]), do: [timeout: @timeout]
  defp process_request_options([timeout: _t] = opts), do: opts
  defp process_request_options(opts), do: Keyword.merge(opts, [timeout: @timeout])

  defp process_request_body(req) when is_binary(req), do: req
  defp process_request_body(req), do: Poison.encode!(req)

  defp process_response_body(""), do: ""
  defp process_response_body(body) do
    body
    |> Poison.decode!(keys: :atoms)
  end

  def get_body(url), do: get(url) 
  def get_body(url, pid), do: get(url, %{}, stream_to: pid)

  def post_body(url, params, headers) do
    post(url, params, headers)
  end
end
