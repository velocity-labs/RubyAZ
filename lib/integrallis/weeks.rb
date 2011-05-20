module Integrallis
  class Weeks
    def self.weeks_for_month (month = nil, year = nil, monday_is_first = true)
      dotw_short = monday_is_first ? Date::ABBR_DAYNAMES.rotate : Date::ABBR_DAYNAMES
      today = Date.today
      month ||= today.month
      year ||= today.year
      beginning_of_month = Date.new(year, month, 1) 
      end_of_month = beginning_of_month.end_of_month
      weeks = []
      week = Array.new(7, nil)
      dow = nil
      (beginning_of_month..end_of_month).each do |day|
        dow = dotw_short.index(day.strftime("%a")) + 1
        week[dow - 1] = day
        if (dow == 7) 
      	  weeks << week
      	  week = Array.new(7, nil)
        end	
      end
      weeks << week if (dow != 7)
      weeks
    end
  end
end