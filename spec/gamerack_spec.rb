require 'rspec'
require 'rack'
require 'rack/test'
require_relative '../lib/gameracker.rb'

RSpec.describe Game do 

  include Rack::Test::Methods 

  describe '#routs' do

    let(:app) { Game }

    context 'go to /' do
      let(:response) { get '/' }
      let(:path)     { File.expand_path('../../lib/views/index.html', __FILE__) }
    
      it 'returns status 200 ' do
        expect(response.status).to eq 200
      end
    end 

    context 'return error404' do
      let(:response) { get '/error404' }
      let(:path)     { File.expand_path('../../lib/views/error404.html', __FILE__) }
     
      it 'returns status 404 ' do
        expect(response.status).to eq 404
      end
    end    

    context 'go to /rules' do
      let(:response) { get '/rules' }
      let(:path)     { File.expand_path('../../lib/views/rules.html', __FILE__) }      

      it 'returns status 200 ' do
        expect(response.status).to eq 200
      end
    end
    context 'go to /statistics' do
      let(:response) { get '/statistics' }
      let(:path)     { File.expand_path('../../lib/views/statistics.html', __FILE__) }
      
      it 'returns status 200 ' do
        expect(response.status).to eq 200
      end
    end        
  end
end