defmodule HolidaysWeb.HolidaysController do
  use HolidaysWeb, :controller

  def index(conn, %{"country" => country, "start_date" => start_date, "end_date" => end_date}) do
    with {:ok, holidays} <- Holidays.get_by_country(country, start_date, end_date) do
      render(conn, "holidays.json", %{holidays: holidays})
    end

    # TODO :: Error handling
  end

  def create(conn, %{"country" => country, "date" => date, "name" => name}) do
    with {:ok, holiday} <- Holidays.add_holiday(country, date, name) do
      render(conn, "holiday.json", %{holiday: holiday})
    end
  end

  def calendar(conn, %{"country" => country, "start_date" => start_date, "end_date" => end_date}) do
    with {:ok, holidays} <- Holidays.get_by_country(country, start_date, end_date),
         ical_data <- Holidays.to_ical(holidays) do
      conn
      |> put_resp_content_type("application/ics")
      |> put_resp_header("content-disposition", "attachment; filename=calendar.ics")
      |> send_resp(:ok, ical_data)
    end
  end
end
