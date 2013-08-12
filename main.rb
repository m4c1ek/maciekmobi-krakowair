require 'sinatra'
require 'httparty'
require 'json'
require_relative 'lib/converter/air_parameter'

PARAMETER_URL = 'http://monitoring.krakow.pios.gov.pl/iseo/aktualne_parametr.php?parametr='

PARAMETERS_MAP = {
	'PM10' => '24',
	'NO' => '02',
	'SO2' => '01',
	'TP' => '54',
	'NO2' => '03',
	'CO' => '04',
	'03' => '08',
	'NOx' => '12',
	'PM25' => '39',
	'PA' => '53',
	'C6H6' => 'V4'
}

get '/parameters' do
	query_params = query_params_from_string(request.query_string)
	check_valid_params(query_params)
	url = url_from_params(query_params)
	content_type 'application/json'
	response = HTTParty.get(url)
	Converter::AirParameter.new.convert(response.body).to_json
end

get '/ping' do
	content_type 'text/plain'
	'pong'
end

def query_params_from_string(s)
	s.split('&').inject({}){|params, value| values=value.split('=');params[values[0].to_sym]=values[1]; params}
end

def url_from_params(p)
	id = p[:id] ? p[:id] : PARAMETERS_MAP[p[:name]]
	p PARAMETER_URL + id
	return PARAMETER_URL + id
end

def check_valid_params(query_params)
	halt 405, 'Ambiguous Query Parameters' if !query_params[:id].nil? && !query_params[:name].nil?
	halt 400, "Unknown Parameters, Supported parameters -- id: #{PARAMETERS_MAP.values} -- name: #{PARAMETERS_MAP.keys}" if (!PARAMETERS_MAP.has_key?(query_params[:name]) && !PARAMETERS_MAP.has_value?(query_params[:id].to_s))
end