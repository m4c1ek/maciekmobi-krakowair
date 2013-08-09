require 'sinatra'
require 'httparty'
require 'json'
require_relative 'lib/converter/air_parameter'

parameters_map = {
	'PM10' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=24',
	'NO' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=02',
	'SO2' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=01',
	'TP' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=54',
	'NO2' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=03',
	'CO' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=04',
	'03' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=08',
	'NOx' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=12',
	'PM25' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=39',
	'PA' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=53',
	'C6H6' => 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr=V4'
}

get '/today/:name' do
	content_type 'application/json'
	p params[:name]
	p parameters_map[params[:name]]
	response = HTTParty.get(parameters_map[params[:name]])
	Converter::AirParameter.new.convert(response.body).to_json
end

get '/ping' do
	content_type 'text/plain'
	'pong'
end
