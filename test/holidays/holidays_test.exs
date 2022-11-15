defmodule Holidays.HolidaysTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!

  describe "get_by_country/3" do
    test "successfully get holidays" do
      expect(RedisMock, :get_between, fn _, _, _ -> {:ok, []} end)

      assert {:ok, holidays} = Holidays.get_by_country("ee", "2022-08-01", "2022-08-30")

      assert [
               %Holidefs.Holiday{
                 name: "Day of Restoration of Independence",
                 raw_date: ~D[2022-08-20],
                 observed_date: ~D[2022-08-20],
                 date: ~D[2022-08-20],
                 uid: "ee-2022-25b87ed2738c35b6ac61ae054733c359",
                 informal?: false
               }
             ] = holidays
    end
  end

  describe "add_holiday/3" do
    test "successfully add holiday" do
      country = "ee"
      date = "2022-11-15"
      name = "some_nm"

      expect(RedisMock, :add, fn ^country, _event -> {:ok, true} end)

      assert {:ok, holiday} = Holidays.add_holiday(country, date, name)
      assert %{name: ^name} = holiday
    end
  end
end
