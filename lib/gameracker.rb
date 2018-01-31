require 'codebreaker'
require 'erb'


class Game
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)      
    @request = Rack::Request.new(env)
    @game = Codebreaker::Game.new
    @start = false
    @current_user = nil
    @a = {1 => 12}
    @gg = @request.cookies['current_user']
  end

  def response
    case @request.path
    when '/' then render_view('index.html.erb')
    when '/rules' then render_view('rules.html.erb')
    when '/game' then new_game
    when '/statistics' then render_view('statistics.html.erb')
    when '/game' then render_view('game.html.erb')
    else Rack::Response.new('Not Found', 404)
    end
  end  

  def new_game
    @start = true
    @guess_code = []
    a = rand(4)
    @guess_code << a
    return render_view('game.html.erb')
    
  end

  def render_view(template)
    Rack::Response.new(render(template)) do |response|
      unless @gg
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        string = (0...50).map { o[rand(o.length)] }.join
        response.set_cookie("current_user", {:value => string, :path => "/", :expires => Time.now+24*60*60})
      end
      response.set_cookie("result", {:value => @a, :path => "/", :expires => Time.now+24*60*60})

    end
  end
  
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end  
end
