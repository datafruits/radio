Bundler.require
require_relative "../time_parser"

describe TimeParser do
  it "gets the redis key based on a time" do
    @radio_name = "datafruits"
    @date = Date.today.strftime("%m%d%Y")
    ENV['RADIO_NAME'] = @radio_name

    time1 = Chronic.parse("today at 9:35 pm")
    time2 = Chronic.parse("today at 9:00 pm")
    time3 = Chronic.parse("today at 6:40 am")
    time4 = Chronic.parse("today at 11:50 am")
    expect(TimeParser.get_key_for_current_time(time1)).to eq("#{@radio_name}:schedule:#{@date}:21h30m")
    expect(TimeParser.get_key_for_current_time(time2)).to eq("#{@radio_name}:schedule:#{@date}:21h00m")
    expect(TimeParser.get_key_for_current_time(time3)).to eq("#{@radio_name}:schedule:#{@date}:06h30m")
    expect(TimeParser.get_key_for_current_time(time4)).to eq("#{@radio_name}:schedule:#{@date}:11h45m")
  end
end
