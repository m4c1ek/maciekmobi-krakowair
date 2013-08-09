require 'nokogiri'
require 'json'


class String
  def is_integer?
    self.to_i.to_s == self
  end

  def is_float?
    !!Float(self) rescue false
  end

end

module Converter
	class AirParameter
		def convert(html)
			page = Nokogiri::HTML(html)
			rows = page.css('body table tr')
			time_row = rows[1]
			date = Converter::AirParameter.new.date_from_html(html)
			return data_rows_values(rows, time_row, date)
		end

		def date_from_html(html)
			time_components = html.scan(/(\d{4})\-(\d{2})\-(\d{2})/)
			return (Time.now.to_i - (Time.now.to_i % (60*60*24)) - 60*60*2) if time_components.empty? 
			return Time.gm(time_components[0][0], time_components[0][1], time_components[0][2]).to_i - 60*60*2
		end

		def data_row_values(row, time_row, date)
			row_values = row_values(row)
			time_row_values = row_values(time_row)
			location = row_location(row)
			unit = row_unit(row)
			combined_values = []
			time_row_values.each_with_index { |value, i|
				if (!value.nil? && !row_values[i].nil?) 
					then combined_values << {:timestamp => date+(value*60*60), :value => row_values[i], :unit => unit, :location => location } 
				end 
			}
			return {:data => combined_values }
		end

		def data_rows_values(rows, time_row, date)
			all_rows = {:data => []}
			rows.select{|row| data_row?(row)}.each {|data_row| all_rows[:data] = data_row_values(data_row, time_row, date)[:data] | all_rows[:data] }
			return all_rows
		end

		def data_row?(row)
			return false if time_row?(row) 
			numbers = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? || text.is_float?}
			return numbers.size > 0
		end

		def time_row?(row)
			hours = (1..24).to_a
			values = row.css('td').map {|td| td.text.strip}.select {|text| text.is_integer? }.map {|text| text.to_i}
			only_hours = (hours - (hours & values)).length == 0
			return only_hours
		end

		def time_row(rows) 
			rows.select {|row| time_row?(row)}.first		
		end

		def each_data_row(html)
			time = date_from_html(html)
			time_row = time_row(each_row(html))
			each_row(html) {|row| yield data_row_values(row, time_row, time) if data_row?(row)}
		end

		def each_row(html)
			page = Nokogiri::HTML(html)
			rows = page.css('body table tr')
			rows.each {|row| yield row if block_given?}
			return rows
		end
		
		protected

		def row_values(row)
			l = ->(td) { 
				value = td.text.strip
				return value.to_i if value.is_integer?
				return value.to_f if value.is_float?
				return nil 
			}

			values = row.css('td').map { |td| 
				l.call(td)
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
