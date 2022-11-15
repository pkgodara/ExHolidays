defmodule Holidays.HolidaysTest do
  use ExUnit.Case

  describe "get_by_country/3" do
    test "successfully get holidays" do
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
end
