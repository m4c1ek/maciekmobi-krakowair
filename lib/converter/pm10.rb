require 'nokogiri'
require 'json'

module Converter
	class PM10
		def convert(html)
			page = Nokogiri::HTML(html)
			timestamps = page.css('body table tbody')[1]

			data = { :data => [
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" }, 
				{ :timestamp => 12, :value => 50, :location => "Krakow - Krowodza", :unit => "µg/m" } 
				] }
			return data
		end

		def dateFromHtml(html)
			timeComponents = html.scan(/(\d{4})\-(\d{2})\-(\d{2})/)
			return (Time.now.to_i - (Time.now.to_i % (60*60*24)) + 60*60*2) if timeComponents.empty? 
			return Time.gm(timeComponents[0][0], timeComponents[0][1], timeComponents[0][2]).to_i + 60*60*2
		end
	end
end
