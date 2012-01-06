require 'sinatra'

root_dir = File.dirname(__FILE__)

set :environment, :production
set :root, root_dir
set :app_file, File.join(root_dir, 'mm.rb')
disable :run

require File.join( File.dirname(__FILE__), 'mm.rb' )

run Sinatra::Application

