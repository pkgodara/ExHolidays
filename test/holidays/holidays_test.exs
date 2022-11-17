defmodule Holidays.HolidaysTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!

  describe "get_by_country/3" do
    test "successfully get holidays" do
      expect(StoreMock, :get_between, fn _, _, _ -> {:ok, []} end)

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

    test "successfully get holidays, merge from redis, in order" do
      manual = %{
        date: Date.from_iso8601!("2022-08-21"),
        name: "some",
        uid: "ee-2022-25b87ed2738c35b6ac61ae054733cavd"
      }

      expect(StoreMock, :get_between, fn _, _, _ -> {:ok, [manual]} end)

      assert {:ok, holidays} = Holidays.get_by_country("ee", "2022-08-01", "2022-08-30")

      assert [
               %Holidefs.Holiday{
                 name: "Day of Restoration of Independence",
                 raw_date: ~D[2022-08-20],
                 observed_date: ~D[2022-08-20],
                 date: ~D[2022-08-20],
                 uid: "ee-2022-25b87ed2738c35b6ac61ae054733c359",
                 informal?: false
               },
               ^manual
             ] = holidays
    end

    test "successfully get holidays, override from redis, in order" do
      manual1 = %{
        date: Date.from_iso8601!("2022-08-01"),
        name: "some",
        uid: "ee-2022-25b87ed2738c35b6ac61ae054733cavd"
      }

      override_date = Date.from_iso8601!("2022-08-15")

      manual2 = %{
        date: override_date,
        name: "some_name_2",
        uid: "ee-2022-25b87ed2738c35b6ac61ae054733c359"
      }

      expect(StoreMock, :get_between, fn _, _, _ -> {:ok, [manual1, manual2]} end)

      assert {:ok, holidays} = Holidays.get_by_country("ee", "2022-08-01", "2022-08-30")

      assert [
               ^manual1,
               %{
                 date: ^override_date,
                 uid: "ee-2022-25b87ed2738c35b6ac61ae054733c359"
               }
             ] = holidays
    end
  end

  describe "add_holiday/3" do
    test "successfully add holiday" do
      country = "ee"
      date = "2022-11-15"
      name = "some_nm"

      expect(StoreMock, :add, fn ^country, _event -> {:ok, true} end)

      assert {:ok, holiday} = Holidays.add_holiday(country, date, name)
      assert %{name: ^name} = holiday
    end

    test "successfully add holiday with correct uid" do
      country = "ee"
      date1 = "2022-11-15"
      date2 = "2022-11-16"
      date3 = "3033-01-01"
      name = "some_nm"

      expect(StoreMock, :add, 3, fn ^country, _event -> {:ok, true} end)

      assert {:ok, holiday} = Holidays.add_holiday(country, date1, name)
      assert %{name: ^name, uid: uid} = holiday

      assert {:ok, holiday} = Holidays.add_holiday(country, date2, name)
      assert %{name: ^name, uid: ^uid} = holiday

      assert {:ok, holiday} = Holidays.add_holiday(country, date3, name)
      assert %{name: ^name, uid: other_uid} = holiday
      refute other_uid == uid
    end
  end
end
