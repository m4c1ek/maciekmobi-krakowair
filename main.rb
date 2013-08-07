require 'sinatra'
require 'httparty'
require 'json'
require_relative 'lib/converter/pm10'

get '/' do
	content_type 'application/json'
	response = HTTParty.get('http://213.17.128.227/iseo/aktualne_parametr.php?parametr=24')
	Converter::PM10.new.convert(response.body).to_json
end
