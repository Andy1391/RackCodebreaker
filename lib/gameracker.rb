require 'codebreaker'
require 'erb'

class Game

  CODE_FILENAME = 'guess_code'
  STATISTIC_FILENAME = 'statistic'
  CODE_SIZE = 4
  ARRAY_SIZE = 0..3
  RANGE_NUMBERS = 1..6
  TOKEN_SIZE = 0..50
  ATTEMPTS = 7 

  attr_accessor :atempts   

  def self.call(env)
    new(env).response.finish    
  end

  def initialize(env)      
    @request = Rack::Request.new(env)
    @current_user = nil    
    @gg = @request.cookies['current_user']
    @guess_code = Array.new
    @cook = @request.cookies['secret_code']
    @attempts = @request.cookies['atempts']
  end

  def response
    case @request.path 
    when '/' then render_view('index.html.erb')  
    when '/rules' then render_view('rules.html.erb') 
    when '/update_name'
      Rack::Response.new do |response|
        response.set_cookie('user_name', @request.params['user_name'])
        response.redirect('/')
      end      
    when '/game' then guess_code
    when '/statistics' then render_view('statistics.html.erb')
    when '/game' then atempts
    else Rack::Response.new('Not Found', 404)
    end
  end

  private

  def user_name
    @request.cookies['user_name'] || 'Player'
  end

  def start
    save_code_to_file        
  end  

  def random_code
    @secret_code = @cook.split('').map(&:to_i)
    @secret_code.delete(0)
    @secret_code
  end  

  def attempts
    Rack::Response.new do |response|
        b = @attempts.to_i
        response.set_cookie("atempts", { value: b - 1})
        response.redirect('/')
    end      



    #   Rack::Response.new do |response| 
    #     @attempts = @request.cookies['atempts'].to_i       
    #     unless @guess_code.join == random_code.join
    #       b = @attempts - 1
    #     end      
    #     response.set_cookie("atempts", {:value => b})
    # end
  end

  def guess_code
    @guess_code << @request.params['user_code'].to_i 
    return render_view('game.html.erb')
  end 

  def save_code_to_file    
    f = File.open(CODE_FILENAME, 'a') do |f|
    f.write("#{@request.params['user_code']}  " + "#{count_plus_and_minus}   <br>" )   
    end
  end

  def read_code_from_file    
    file = File.open(CODE_FILENAME, 'r') { |f| f.read } 
  end

  def delete_code_file
    File.delete(CODE_FILENAME)
  end

  def save_statistic_data    
    f = File.open(STATISTIC_FILENAME, 'a') do |f|
    f.write("Player: #{@request.cookies['user_name']}  " + "ATTEMPTS: #{@attempts}   <br>" )   
    end
  end

  def load_statistic
    file = File.open(STATISTIC_FILENAME, 'r') { |f| f.read }    
  end

  def win?
    @guess_code.join == random_code.join    
  end

  def count_plus
    plus = []
      CODE_SIZE.times do |i| 
        if @guess_code.join.each_char.map(&:to_i)[i] == random_code.join.each_char.map(&:to_i)[i]
          plus << "+"
        end
      end
    plus
  end

  def count_minus
    minus = []
      CODE_SIZE.times do |i|
        if @guess_code.join.each_char.map(&:to_i).include?(random_code.join.each_char.map(&:to_i)[i]) && (@guess_code.join.each_char.map(&:to_i)[i] != random_code.join.each_char.map(&:to_i)[i])      
          minus << "-"
        end
      end
    minus
  end 

  def count_plus_and_minus
    count = []
    count << count_plus.concat(count_minus)
    count.join
  end

  def generate_new_code    
    @cook = false
  end

  def delete_current_game_data
    generate_new_code
    delete_code_file    
  end

  def render_view(template)
    Rack::Response.new(render(template)) do |response|       
        response.set_cookie("atempts", {:value => ATTEMPTS, :path => "/", :expires => Time.now+24*60*60})      
      unless @cook
        code = (RANGE_NUMBERS).to_a.sort{ rand() - 0.5 }[ARRAY_SIZE]
        response.set_cookie("secret_code", {:value => code, :path => "/", :expires => Time.now+24*60*60})        
      end         
    end
  end
  
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end  
end
