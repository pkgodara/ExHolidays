defmodule HolidaysWeb.PageControllerTest do
  use HolidaysWeb.ConnCase

  import Mox
  setup :verify_on_exit!

  describe "/index" do
    test "successfully returns holidays in range", %{conn: conn} do
      expect(StoreMock, :get_between, fn _, _, _ -> {:ok, []} end)

      query = %{country: "ee", start_date: "2022-08-01", end_date: "2022-08-30"}
      url = Routes.holidays_path(conn, :index, query)

      assert %{
               "holidays" => [
                 %{"date" => "2022-08-20", "name" => "Day of Restoration of Independence"}
               ]
             } = json_response(get(conn, url), 200)
    end
  end

  describe "/create" do
    test "successfully create holiday on given date", %{conn: conn} do
      country = "ee"
      date = "2022-11-15"
      name = "some_nm"

      expect(StoreMock, :add, fn ^country, _event -> {:ok, true} end)

      params = %{country: country, date: date, name: name}
      conn = post(conn, Routes.holidays_path(conn, :create), params)

      assert %{"date" => ^date, "name" => ^name} = json_response(conn, 200)
    end
  end
end
