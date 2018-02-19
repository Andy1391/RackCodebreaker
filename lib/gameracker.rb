require 'codebreaker'
require 'erb'
require 'redis'
require 'json'

class Game

  CODE_FILENAME = 'guess_code.json'
  CODE_SIZE = 4
  RANGE_NUMBER = 1..6

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)      
    @request = Rack::Request.new(env)    
    @current_user = nil    
    @gg = @request.cookies['current_user']
    @guess_code = Array.new
    @cook = @request.cookies['secret_code']      
  end

  def response
    case @request.path
    # when '/' then render_view('index.html.erb')
    when '/' then generate_secret_code && render_view('index.html.erb') 
    when '/rules' then render_view('rules.html.erb')
    when '/game' then game
    when '/statistics' then render_view('statistics.html.erb')
    when '/game' then render_view('game.html.erb')
    else Rack::Response.new('Not Found', 404)
    end
  end

  def start
    @game = Codebreaker::CodebreakerGame.new
    @game.begin 
  end 

  def generate_secret_code
    Rack::Response.new do |response|
      code = Array.new(4){rand(1..6)}
      response.set_cookie("secret_code", {:value => code, :path => "/", :expires => Time.now+24*60*60}) 
    end
    # return render_view('index.html.erb') 
  end 

  def game
    @guess_code << @request.params['user_code'].to_i 
    return render_view('game.html.erb')
  end 

  def save_code_to_file    
    f = File.open(CODE_FILENAME, 'a') do |f|
    f.write("#{@request.params['user_code']} \n ")   
    end
  end

  def read_code_from_file    
    file = File.open(CODE_FILENAME, 'r') { |f| f.read } 
  end

  def delete_code_file
    File.delete(CODE_FILENAME)
  end

  def win?
    @guess_code.join == @secret_code.join
  end

  def render_view(template)
    Rack::Response.new(render(template)) do |response|
      unless @gg
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        string = (0...50).map { o[rand(o.length)] }.join
        response.set_cookie("current_user", {:value => string, :path => "/", :expires => Time.now+24*60*60})        
      end         
    end
  end
  
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end  
end
