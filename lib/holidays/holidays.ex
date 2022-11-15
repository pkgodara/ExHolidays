defmodule Holidays do
  @moduledoc """
  Holidays context.
  """

  alias Holidays.Redis

  @start_time {00, 00, 00}
  @end_time {23, 59, 59}

  @doc """
  Date in format 'YYYY-MM-DD'

  Does not checks for duplicates b/w Preset and Manually Set holidays.
  Can be Out of Order.
  """
  def get_by_country(country, start_dt, end_dt) do
    with {:ok, start_dt} <- Date.from_iso8601(start_dt),
         {:ok, end_dt} <- Date.from_iso8601(end_dt),
         {:ok, holidefs} <- Holidefs.between(country, start_dt, end_dt),
         {:ok, manual} <- Redis.get_between(country, start_dt, end_dt) do
      {:ok, holidefs ++ manual}
    end
  end

  @doc """
  Example -

  {:ok, holidays} = Holidays.get_by_country("ee", "2022-01-01", "2022-11-01")
  Holidays.to_ical holidays
  """
  def to_ical(holidays) when is_list(holidays) do
    events = to_ical_events(holidays)

    %ICalendar{events: events} |> ICalendar.to_ics(vendor: "Holidefs")
  end

  def add_holiday(country, date, name) do
    with {:ok, date} <- Date.from_iso8601(date),
         holiday <- %{date: date, name: name},
         {:ok, true} <- Redis.add(country, holiday) do
      {:ok, holiday}
    end
  end

  defp to_ical_events(holidays) do
    Enum.map(holidays, fn %{name: name, date: date} ->
      date = Date.to_erl(date)

      %ICalendar.Event{summary: name, dtstart: {date, @start_time}, dtend: {date, @end_time}}
    end)
  end
end
