require 'sinatra'
require 'httparty'
require 'json'
require_relative 'lib/converter/pm10'


parameters_map = {
	'PM10' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=24',
	'NO' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=02',
	'SO2' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=01',
	'TP' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=54'
}

get '/today/:name' do
	content_type 'application/json'
	p params[:name]
	p parameters_map[params[:name]]
	response = HTTParty.get(parameters_map[params[:name]])
	Converter::PM10.new.convert(response.body).to_json
end

get '/ping' do
	content_type 'text/plain'
	'pong'
end
