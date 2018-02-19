require './lib/gameracker'
require 'codebreaker'
require 'redis'
require 'json'

use Rack::Static, urls: ['/stylesheets'], root: 'public'
run Game