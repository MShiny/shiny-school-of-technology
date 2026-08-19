require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "time_based_greeting returns a morning greeting before noon" do
    travel_to Time.zone.local(2026, 1, 1, 9, 0, 0) do
      assert_equal "Good morning", time_based_greeting
    end
  end

  test "time_based_greeting returns an afternoon greeting before 6pm" do
    travel_to Time.zone.local(2026, 1, 1, 14, 0, 0) do
      assert_equal "Good afternoon", time_based_greeting
    end
  end

  test "time_based_greeting returns an evening greeting after 6pm" do
    travel_to Time.zone.local(2026, 1, 1, 20, 0, 0) do
      assert_equal "Good evening", time_based_greeting
    end
  end

  test "status_badge falls back to secondary for an unknown status" do
    badge = status_badge("mystery")
    assert_match "text-bg-secondary", badge
    assert_match "Mystery", badge
  end

  test "status_dot maps known statuses to the expected visual class" do
    assert_match "status-success", status_dot("met")
    assert_match "status-warning", status_dot("partial")
    assert_match "status-danger", status_dot("not_met")
    assert_match "status-neutral", status_dot("pending")
  end

  test "status_dot falls back to neutral for an unknown status" do
    assert_match "status-neutral", status_dot("mystery")
  end
end
