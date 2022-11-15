defmodule Holidays.Redis do
  @moduledoc false

  @callback add(country :: String.t(), event :: map()) :: {:ok, true} | {:error, any()}
  @callback get_between(country :: String.t(), start_date :: Date.t(), end_date :: Date.t()) ::
              {:ok, List.t()} | {:error, any()}

  # Proxies
  def add(country, event), do: impl().add(country, event)

  def get_between(country, start_date, end_date),
    do: impl().get_between(country, start_date, end_date)

  defp impl(), do: Application.get_env(:holidays, :redis_impl, Holidays.Redis.Default)
end

defmodule Holidays.Redis.Default do
  @moduledoc false

  def add(country, %{date: date, name: _name} = event) do
    score = Date.to_gregorian_days(date)

    with {:ok, result} <- RedisPool.query(["ZADD", country, score, Jason.encode!(event)]),
         {:ok, true} <- handle_result(:ZADD, result) do
      {:ok, true}
    end
  end

  def get_between(country, start_dt, end_dt) do
    min_score = Date.to_gregorian_days(start_dt)
    max_score = Date.to_gregorian_days(end_dt)

    with {:ok, result} <- RedisPool.query(["ZREVRANGEBYSCORE", country, max_score, min_score]),
         {:ok, true} <- handle_result(:ZRANGE, result) do
      events = parse_events(result)
      {:ok, events}
    end
  end

  defp parse_events(raw_events) do
    Enum.map(raw_events, fn data ->
      event = Jason.decode!(data, keys: :atoms)
      %{event | date: Date.from_iso8601!(event.date)}
    end)
  end

  defp handle_result(:ZADD, "0"), do: {:ok, true}
  defp handle_result(:ZADD, "1"), do: {:ok, true}
  defp handle_result(:ZADD, result), do: {:error, result}

  defp handle_result(:ZRANGE, result) when is_list(result), do: {:ok, true}
  defp handle_result(:ZRANGE, result), do: {:error, result}
end
