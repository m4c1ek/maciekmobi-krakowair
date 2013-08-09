require 'nokogiri'
require 'httparty'
require_relative '../lib/converter/air_parameter'

describe Converter::AirParameter do

	p10_file = File.dirname(__FILE__) + "/html/pm10.html"
	tp_file = File.dirname(__FILE__) + "/html/tp.html"

	it "should convert to map" do
		contents = File.open(p10_file, "r").read
		Converter::AirParameter.new.convert(contents)[:data].length.should == 89
	end

	it "should parse date" do
		contents = File.open(p10_file, "rb").read
		date = Converter::AirParameter.new.date_from_html(contents)
		date.should == 1375135200
	end

	it "should give today (0:00 GMT+2) on no date string" do
		date = Converter::AirParameter.new.date_from_html("<html>no date in this html</html>")
		expected_time = Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2
		date.should == expected_time
	end
	
	it "should detect data row" do		
		page = Nokogiri::HTML(File.open(p10_file, "r").read)
		rows = page.css('body table tr')
		Converter::AirParameter.new.data_row?(rows[0]).should == false
		Converter::AirParameter.new.data_row?(rows[1]).should == false
		Converter::AirParameter.new.data_row?(rows[2]).should == true
	end

	it "should detect time row" do		
		page = Nokogiri::HTML(File.open(p10_file, "r").read)
		rows = page.css('body table tr')
		Converter::AirParameter.new.time_row?(rows[0]).should == false
		Converter::AirParameter.new.time_row?(rows[1]).should == true
		Converter::AirParameter.new.time_row?(rows[2]).should == false
	end

	it "should get data row values" do
		contents = File.open(p10_file, "r").read
		page = Nokogiri::HTML(contents)
		rows = page.css('body table tr')
		row = rows[2]
		time_row = rows[1]
		date = Converter::AirParameter.new.date_from_html(contents)
		Converter::AirParameter.new.data_row_values(row, time_row, date).should == 
		{ :data => [{:timestamp=>1375138800, :value=>34, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375142400, :value=>35, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375146000, :value=>37, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375149600, :value=>50, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375153200, :value=>64, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375156800, :value=>27, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375160400, :value=>24, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375164000, :value=>21, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375167600, :value=>18, :unit=>"µg/m3", :location => "Tarnów"},
         {:timestamp=>1375171200, :value=>19, :unit=>"µg/m3", :location => "Tarnów"}] }
	end

	it "should find time row" do
		contents = File.open(p10_file, "r").read
		rows = Converter::AirParameter.new.each_row(contents)
		time_row  = Converter::AirParameter.new.time_row(rows)
		time_row.nil?.should == false
	end

	it "should get data rows as block" do
		contents = File.open(p10_file, "r").read
		Converter::AirParameter.new.each_data_row(contents){|row| row[:data][0][:location].nil?.should == false}
		Converter::AirParameter.new.each_data_row(contents){|row| row[:data].length.should > 0}
	end

	it "should get data pm10 rows values" do
		contents = File.open(p10_file, "r").read
		page = Nokogiri::HTML(contents)
		rows = page.css('body table tr')
		time_row = rows[1]
		date = Converter::AirParameter.new.date_from_html(contents)
		Converter::AirParameter.new.data_rows_values(rows, time_row, date)[:data].length.should == 89
	end

	it "should get data tp rows values" do
		contents = File.open(tp_file, "r").read
		page = Nokogiri::HTML(contents)
		rows = page.css('body table tr')
		time_row = rows[1]
		date = Converter::AirParameter.new.date_from_html(contents)
		Converter::AirParameter.new.data_rows_values(rows, time_row, date)[:data].length.should == 20
	end

	# it "integration test" do
	# 	response = HTTParty.get('http://213.17.128.227/iseo/aktualne_parametr.php?parametr=24')
	# 	p Converter::AirParameter.new.convert(response.body)	
	# end
end
