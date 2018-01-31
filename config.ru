require './lib/gameracker'

use Rack::Static, urls: ['/stylesheets'], root: 'public'
run Game