defmodule HolidaysWeb.HolidaysView do
  use HolidaysWeb, :view

  def render("holidays.json", %{holidays: holidays}) do
    %{
      holidays: render_many(holidays, __MODULE__, "holiday.json", as: :holiday)
    }
  end

  def render("holiday.json", %{holiday: holiday}) do
    %{
      date: Date.to_iso8601(holiday.date),
      name: holiday.name
    }
  end
end
