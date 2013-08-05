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
		date = Converter::PM10.new.date_from_html(contents)
		date.should == 1375135200
	end

	it "should give today (0:00 GMT+2) on no date string" do
		date = Converter::PM10.new.date_from_html("<html>no date in this html</html>")
		expected_time = Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2
		date.should == expected_time
	end
	
	it "should detect data row" do		
		page = Nokogiri::HTML(File.open("./html/pm10.html", "r").read)
		rows = page.css('body table tr')
		Converter::PM10.new.data_row?(rows[0]).should == false
		Converter::PM10.new.data_row?(rows[1]).should == false
		Converter::PM10.new.data_row?(rows[2]).should == true
	end

	it "should detect time row" do		
		page = Nokogiri::HTML(File.open("./html/pm10.html", "r").read)
		rows = page.css('body table tr')
		Converter::PM10.new.time_row?(rows[0]).should == false
		Converter::PM10.new.time_row?(rows[1]).should == true
		Converter::PM10.new.time_row?(rows[2]).should == false
	end

	it "should get data row values" do
		contents = File.open("./html/pm10.html", "r").read
		page = Nokogiri::HTML(contents)
		rows = page.css('body table tr')
		row = rows[2]
		time_row = rows[1]
		date = Converter::PM10.new.date_from_html(contents)
		Converter::PM10.new.data_row_values(row, time_row, date).should == 
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

	it "should find time row" do
		contents = File.open("./html/pm10.html", "r").read
		rows = Converter::PM10.new.each_row(contents)
		time_row  = Converter::PM10.new.time_row(rows)
		time_row.nil?.should == false
	end

	it "should get data rows as block" do
		contents = File.open("./html/pm10.html", "r").read
		Converter::PM10.new.each_data_row(contents){|row| row[:location].nil?.should == false}
		Converter::PM10.new.each_data_row(contents){|row| row[:data].length.should > 0}
	end
end
