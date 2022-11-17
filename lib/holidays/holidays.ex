defmodule Holidays do
  @moduledoc """
  Holidays context.
  """

  alias Holidays.Store

  @start_time {00, 00, 00}
  @end_time {23, 59, 59}

  @doc """
  Date in format 'YYYY-MM-DD'

  For same name, if multiple manual holidays are added, returns the highest date.
  Results ordered by ascending dates.
  """
  def get_by_country(country, start_dt, end_dt) do
    with {:ok, start_dt} <- Date.from_iso8601(start_dt),
         {:ok, end_dt} <- Date.from_iso8601(end_dt),
         {:ok, holidefs} <- Holidefs.between(country, start_dt, end_dt),
         {:ok, manual} <- Store.get_between(country, start_dt, end_dt) do
      holidays =
        (manual ++ holidefs)
        |> Enum.uniq_by(& &1.uid)
        |> Enum.sort_by(& &1.date, &(Date.compare(&1, &2) != :gt))

      {:ok, holidays}
    end
  end

  @doc """
  Generates ics file content from given holidays list

  Example -
  {:ok, holidays} = Holidays.get_by_country("ee", "2022-01-01", "2022-11-01")
  Holidays.to_ical(holidays)
  """
  def to_ical(holidays) when is_list(holidays) do
    events = to_ical_events(holidays)

    %ICalendar{events: events} |> ICalendar.to_ics(vendor: "Holidefs")
  end

  @doc """
  Add holiday, overrides default Holidefs config based on names.

  Overrides if names in the same locale.
  """
  def add_holiday(country, date, name) do
    with name <- String.trim(name),
         {:ok, date} <- Date.from_iso8601(date),
         {:ok, holiday} <- build_holiday(country, date, name),
         {:ok, true} <- Store.add(country, holiday) do
      {:ok, holiday}
    end
  end

  defp to_ical_events(holidays) do
    Enum.map(holidays, fn %{name: name, date: date} ->
      date = Date.to_erl(date)

      %ICalendar.Event{summary: name, dtstart: {date, @start_time}, dtend: {date, @end_time}}
    end)
  end

  defp build_holiday(country, date, name) do
    with {year, _mm, _dd} <- Date.to_erl(date),
         uid <- generate_uid(country, year, name),
         holiday <- %{date: date, name: name, uid: uid} do
      {:ok, holiday}
    end
  end

  defp generate_uid(code, year, name) do
    <<sha1::128, _::32>> = :crypto.hash(:sha, name)

    hash =
      <<sha1::128>>
      |> Base.encode16()
      |> String.downcase()

    "#{code}-#{year}-#{hash}"
  end
end
