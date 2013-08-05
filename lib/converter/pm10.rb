require 'nokogiri'
require 'json'


class String
  def is_integer?
    self.to_i.to_s == self
  end
end

module Converter
	class PM10
		def convert(html)
			page = Nokogiri::HTML(html)
			timestamps = page.css('body table tbody tr')

			data = { :data => [
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" } 
				] }
			return data
		end

		def dateFromHtml(html)
			timeComponents = html.scan(/(\d{4})\-(\d{2})\-(\d{2})/)
			return (Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2) if timeComponents.empty? 
			return Time.gm(timeComponents[0][0], timeComponents[0][1], timeComponents[0][2]).to_i - 60*60*2
		end

		def dataFromHtml(html)
			page = Nokogiri::HTML(html)
			rows = page.css('body table tbody tr')
			
		end

		def dataRow?(row)
			return false if timeRow?(row) 
			numbers = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? }
			return numbers.size > 0
		end

		def timeRow?(row)
			hours = (1..24).to_a
			values = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? }.map {|text| text.to_i}
			onlyHours = (hours - (hours & values)).length == 0
			return onlyHours
		end

		def dataRowValues(row, timeRow, date)
			rowValues = rowValues(row)
			timeRowValues = rowValues(timeRow)
			location = rowLocation(row)
			combinedValues = []
			timeRowValues.each_with_index { |value, i|
				if (!value.nil? && !rowValues[i].nil?) 
					then combinedValues << {:timestamp => date+(value*60*60), :value => rowValues[i], :unit => "µg/m3" } 
				end 
			}
			return {:location => location, :data => combinedValues }
		end

		def rowValues(row)
			values = row.css('td').map { |td| 
				value = td.text.strip
				(value.empty? || !value.is_integer?) ? nil : value.to_i
			}
			return values
		end

		def rowLocation(row)
			row.css('td')[0].text.strip
		end

	end
end
