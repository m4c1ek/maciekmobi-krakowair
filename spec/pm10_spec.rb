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
		date.should == 1375135200
	end

	it "should give today (0:00 GMT+2) on no date string" do
		date = Converter::PM10.new.dateFromHtml("<html>no date in this html</html>")
		expectedTime = Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2
		date.should == expectedTime
	end
	
	it "should detect data row" do		
		page = Nokogiri::HTML(File.open("./html/pm10.html", "rb").read)
		rows = page.css('body table tr')
		Converter::PM10.new.dataRow?(rows[0]).should == false
		Converter::PM10.new.dataRow?(rows[1]).should == false
		Converter::PM10.new.dataRow?(rows[2]).should == true
	end

	it "should get data row values" do
		contents = File.open("./html/pm10.html", "rb").read
		page = Nokogiri::HTML(contents)
		rows = page.css('body table tr')
		row = rows[2]
		timeRow = rows[1]
		date = Converter::PM10.new.dateFromHtml(contents)
		Converter::PM10.new.dataRowValues(row, timeRow, date).should == 
		{   :location => "Tarnów", 
			:data => [{:timestamp=>1375138800, :value=>34, :unit=>"µg/m3"},
         {:timestamp=>1375142400, :value=>35, :unit=>"µg/m3"},
         {:timestamp=>1375146000, :value=>37, :unit=>"µg/m3"},
         {:timestamp=>1375149600, :value=>50, :unit=>"µg/m3"},
         {:timestamp=>1375153200, :value=>64, :unit=>"µg/m3"},
         {:timestamp=>1375156800, :value=>27, :unit=>"µg/m3"},
         {:timestamp=>1375160400, :value=>24, :unit=>"µg/m3"},
         {:timestamp=>1375164000, :value=>21, :unit=>"µg/m3"},
         {:timestamp=>1375167600, :value=>18, :unit=>"µg/m3"},
         {:timestamp=>1375171200, :value=>19, :unit=>"µg/m3"}] }
	end
end
