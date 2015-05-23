class TimeParser
  def self.get_key_for_current_time time
    day = time.strftime("%m%d%Y")
    hour = time.strftime("%H")
    minute = get_minutes(time.strftime("%M").to_i)
    "#{ENV['RADIO_NAME']}:schedule:#{day}:#{hour}h#{minute}m"
  end

  private
  def self.get_minutes minute
    if minute.between? 0,14
      return "00"
    elsif minute.between? 15,29
      return "15"
    elsif minute.between? 30,44
      return "30"
    elsif minute.between? 45,59
      return "45"
    end
  end
end
