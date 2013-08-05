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

		def date_from_html(html)
			time_components = html.scan(/(\d{4})\-(\d{2})\-(\d{2})/)
			return (Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2) if time_components.empty? 
			return Time.gm(time_components[0][0], time_components[0][1], time_components[0][2]).to_i - 60*60*2
		end

		def data_from_html(html)
			page = Nokogiri::HTML(html)
			rows = page.css('body table tbody tr')
			
		end

		def data_row?(row)
			return false if time_row?(row) 
			numbers = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? }
			return numbers.size > 0
		end

		def time_row?(row)
			hours = (1..24).to_a
			values = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? }.map {|text| text.to_i}
			only_hours = (hours - (hours & values)).length == 0
			return only_hours
		end

		def data_row_values(row, time_row, date)
			row_values = row_values(row)
			time_row_values = row_values(time_row)
			location = row_location(row)
			unit = row_unit(row)
			combined_values = []
			time_row_values.each_with_index { |value, i|
				if (!value.nil? && !row_values[i].nil?) 
					then combined_values << {:timestamp => date+(value*60*60), :value => row_values[i], :unit => unit } 
				end 
			}
			return {:location => location, :data => combined_values }
		end

		def row_values(row)
			values = row.css('td').map { |td| 
				value = td.text.strip
				(value.empty? || !value.is_integer?) ? nil : value.to_i
			}
			return values
		end

		def row_location(row)
			row.css('td').first.text.strip
		end

		def row_unit(row)
			row.css("td")[1].text
		end
	end
end
