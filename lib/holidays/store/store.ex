defmodule Holidays.Store do
  @moduledoc false

  @callback add(country :: String.t(), event :: map()) :: {:ok, true} | {:error, any()}
  @callback get_between(country :: String.t(), start_date :: Date.t(), end_date :: Date.t()) ::
              {:ok, List.t()} | {:error, any()}

  # Proxies
  def add(country, event), do: impl().add(country, event)

  def get_between(country, start_date, end_date),
    do: impl().get_between(country, start_date, end_date)

  defp impl(), do: Application.get_env(:holidays, :store_impl, Holidays.Store.Redis)
end
