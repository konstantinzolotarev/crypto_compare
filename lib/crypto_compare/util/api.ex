defmodule CryptoCompare.Util.Api do
  @moduledoc false

  use HTTPoison.Base

  @host "https://www.cryptocompare.com/api/data/"
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

  @doc """
  Fetch only actual data from request
  """
  @spec get_body(String.t) :: {:ok, any} | {:error, any}
  def get_body(url), do: get(url) |> fetch_body() |> pick_data()

  @doc """
  Fetch only actual body from request with specified params
  """
  @spec get_body(String.t, [tuple]) :: {:ok, any} | {:error, any}
  def get_body(url, params), do: get(url, %{}, params: params) |> fetch_body() |> pick_data()

  defp fetch_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, body}
  defp fetch_body({:ok, %HTTPoison.Response{status_code: 201, body: body}}), do: {:ok, body}
  defp fetch_body({:error, err}), do: {:error, err}
  defp fetch_body(_), do: {:error, "Something wrong !"}

  defp pick_data({:ok, %{Response: "Success", Data: data}}), do: {:ok, data}
  defp pick_data({:ok, %{Response: "Error"} = data}), do: {:error, data}
  defp pick_data(resp), do: resp
end
