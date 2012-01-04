#!/usr/bin/env ruby

require 'sinatra'
require 'yaml'
require 'json'
require 'log4r'

include Log4r

MOCK_FILE   = File.join(File.dirname(__FILE__), "etc", "mock.yaml")
LOG_FILE    = File.join(File.dirname(__FILE__), 'log', 'mm.log')
LOG_LEVEL   = 'INFO'

# ---------------------------------------------------
JSON_CONTENT_TYPE = { "Content-Type" => "application/json;charset=utf-8" }
HTML_CONTENT_TYPE = { "Content-Type" => "text/html; charset=utf-8" }

if RUBY_VERSION < '1.9'
  puts "Please upgrade to ruby 1.9"
  exit 1
end

# initialzie logging
outputter       = Log4r::FileOutputter.new('MM_LOG_FILE', \
                                            :filename => LOG_FILE)
outputter.level = Log4r::Log4rConfig::LogLevels.index(LOG_LEVEL) + 1
$log            = Logger.new 'Monitoring Mock'
$log.trace      = false
$log.add(outputter)

$log.info "Mock up and running!"

# --- helper ---
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# --- filter ---
before do
  # default content type
  headers JSON_CONTENT_TYPE
end

# --- route matcher ---
class RouteMatcher
  Match = Struct.new(:captures)

  def initialize
    @captures = Match.new([])
  end

  def match(str)
    $routes = YAML.load(File.new(MOCK_FILE))
    @captures unless $routes[str].nil?
  end
end

def route_from_yaml
  RouteMatcher.new
end

# --- initiate status hash ---
$status = Hash.new
$routes = YAML.load(File.new(MOCK_FILE))
$routes.each do |route|
  $status[route.first] = true
end

# --- getter ---
get route_from_yaml do
  path          = request.path_info
  paths         = Array.new
  result        = true
  $status[path] = true if $status[path].nil?

  path.split('/').each do |step|
    if not step.empty?
      prefix = paths.last || ''
      paths << prefix + '/' + step
    end
  end

  paths.each do |step|
    if not $status[step]
      result = false
    end
  end

  if result
    {:status  => 0,
     :output  => "Service OK",
     :options => $routes[path]}.to_json
  else
    {:status  => 2,
     :output  => "Service is broken",
     :options => $routes[path]}.to_json
  end
end

get '/dashboard' do
  headers HTML_CONTENT_TYPE

  @routes = $routes
  @status = $status
  erb :dashboard
end

# --- setter ---
post '/toggle*' do
  path = params[:splat].last

  $status[path] = !$status[path]
  $log.info "Status - " + $status.inspect

  {path.to_sym => $status[path]}.to_json
end

get '/*' do
  return_error( 404, "Nothing found by that route" )
end

post '/*' do
  return_error( 404, "Nothing found by that route" )
end

put '/*' do
  return_error( 404, "Nothing found by that route" )
end

delete '/*' do
  return_error( 404, "Nothing found by that route" )
end

# --- private functions ---
private
def return_error(code, message)
  $log.error message
    redirect '/', code, {:status => 3, :output => message}.to_json
end

