require_relative '../lib/converter/pm10'

describe Converter::PM10 do

	rawdata = { :data => [
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" } 
				] }

	it "should convert to map" do
		contents = File.open("./html/pm10.html", "rb").read
		value = Converter::PM10.new.convert(contents)
		value[:data].size.should > 0
		value.should == rawdata
	end


	it "should parse date" do
		contents = File.open("./html/pm10.html", "rb").read
		date = Converter::PM10.new.dateFromHtml(contents)
		date.should == 1375149600
	end

	it "should give today (0:00 GMT+2) on no date string" do
		date = Converter::PM10.new.dateFromHtml("<html>no date in this html</html>")
		expectedTime = Time.now.to_i - (Time.now.to_i % (60*60*24)) + 60*60*2
		date.should == expectedTime
	end
end

