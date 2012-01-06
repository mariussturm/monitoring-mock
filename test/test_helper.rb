ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'mm'

def app
  Sinatra::Application
end

def json_response
  JSON.parse last_response.body
end

