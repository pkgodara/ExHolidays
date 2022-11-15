defmodule Holidays.Redis do
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

    with {:ok, result} <- RedisPool.query(["ZRANGEBYSCORE", country, min_score, max_score]),
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
