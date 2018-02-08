require './lib/gameracker'
require 'codebreaker'

use Rack::Static, urls: ['/stylesheets'], root: 'public'
run Game