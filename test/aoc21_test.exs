defmodule Aoc21Test do
  use ExUnit.Case
  doctest Aoc21

  test "Day one" do
    assert Aoc21.DayOne.part_one() == 1233
    assert Aoc21.DayOne.part_two() == 1275
  end

  test "Day two" do
    assert Aoc21.DayTwo.part_one() == 1_762_050
    assert Aoc21.DayTwo.part_two() == 1_855_892_637
  end

  test "Day three" do
    assert Aoc21.DayThree.part_one() == 2_648_450
    assert Aoc21.DayThree.part_two() == 2_845_944
  end

  test "Day four" do
    assert Aoc21.DayFour.part_one() == 11774
    assert Aoc21.DayFour.part_two() == 4495
  end

  test "Day five" do
    assert Aoc21.DayFive.part_one() == 6572
    assert Aoc21.DayFive.part_two() == 21466
  end

  test "Day six" do
    assert Aoc21.DaySix.part_one() == 365_131
    assert Aoc21.DaySix.part_two() == 1_650_309_278_600
  end

  test "Day seven" do
    assert Aoc21.DaySeven.part_one() == 340_052
    assert Aoc21.DaySeven.part_two() == 92_948_968
  end

  test "Day eight" do
    assert Aoc21.DayEight.part_one() == 237
    assert Aoc21.DayEight.part_two() == 1_009_098
  end

  test "Day nine" do
    assert Aoc21.DayNine.part_one() == 548
    assert Aoc21.DayNine.part_two() == 786_048
  end
end
