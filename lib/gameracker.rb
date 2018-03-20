require 'codebreaker'
require 'erb'

class Game

  CODE_FILENAME = 'guess_code'
  STATISTIC_FILENAME = 'statistic'
  CODE_SIZE = 4
  ARRAY_SIZE = 0..3
  RANGE_NUMBERS = 1..6  
  ATTEMPTS = 7
  HINTS = 2   

  def self.call(env)
    new(env).response.finish   
  end

  def initialize(env)      
    @request = Rack::Request.new(env)
    @guess_code = Array.new
    @user_code = @request.params['user_code']
    @cook = @request.cookies['secret_code']
    @attempts = @request.cookies['atempts']
    @hints = @request.cookies['hints']
    @current_hint = @request.cookies['current_hint']               
 end

  def response
    case @request.path 
    when '/' then render_view('index.html.erb')    
    when '/rules' then render_view('rules.html.erb')
    when '/statistics' then render_view('statistics.html.erb')    
    when '/update_name' then update_name      
    when '/take_hint' then take_hint
    when '/new_game' then new_game
    when '/attempt' then attempt        
    when '/game' then guess_code
    when '/clear_statistic' then clear_statistic
                                                                                                        
    else Rack::Response.new('Not Found', 404)
    end
  end  

  def user_name
    @request.cookies['user_name'] || 'Player'
  end   

  def random_code
    @secret_code = @cook.split('').map(&:to_i)
    @secret_code.delete(0)
    @secret_code
  end

  def guess_code    
    @guess_code << @request.params['user_code'].to_i    
    return render_view('game.html.erb')
  end  

  def update_name
    Rack::Response.new do |response|
      response.set_cookie('user_name', @request.params['user_name'])      
      response.redirect('/')
    end
  end  

  def new_game
    Rack::Response.new do |response|
      response.set_cookie('atempts', {:value => ATTEMPTS, :path => "/", :expires => Time.now+24*60*60})
      response.set_cookie('hints', {:value => HINTS, :path => "/", :expires => Time.now+24*60*60})
      response.delete_cookie('current_hint')
      response.redirect('/game')
    end      
  end

  def attempt      
    Rack::Response.new do |response|     
      a = @attempts.to_i - 1          
      response.set_cookie('atempts', {:value => a, :path => "/", :expires => Time.now+24*60*60})            
      response.redirect("/game?user_code=#{@request.params['user_code']}")
    end    
  end

  def hint
    @hints.to_i.zero?
  end   

  def take_hint
    Rack::Response.new do |response|
      random_hint = rand(CODE_SIZE)
      hint = random_code[random_hint]                         
      response.set_cookie('current_hint', :value => hint, :path => "/" )
      a = @hints.to_i - 1
      response.set_cookie('hints', {:value => a, :path => "/"})            
      response.redirect('/game')
    end                      
  end  

  def save_code_to_file    
    f = File.open(CODE_FILENAME, 'a') do |f|
    f.write("#{@user_code}" + "#{count_plus_and_minus} <br>" )   
    end
  end

  def read_code_from_file    
    File.open(CODE_FILENAME, 'r') { |f| f.read } 
  end

  def delete_current_game_data
    File.open(CODE_FILENAME, 'w') {|file| file.truncate(0) }
    @cook = nil 
  end

  def save_statistic    
    f = File.open(STATISTIC_FILENAME, 'a') do |f|
    f.write("Player: #{@request.cookies['user_name']}  " + "HINTS: #{@hints}  " + "ATTEMPTS: #{@attempts}   <br>" )   
    end
  end

  def clear_statistic
    File.open(STATISTIC_FILENAME, 'w') {|file| file.truncate(0) }
    return render_view('statistics.html.erb')
  end

  def load_statistic
    file = File.open(STATISTIC_FILENAME, 'r') { |f| f.read }    
  end

  def win?
    @guess_code.join == random_code.join    
  end

  def win
    save_statistic
    delete_current_game_data
  end

  def lose
    @attempts.to_i.zero? && @secret_code != @guess_code.join.each_char.map(&:to_i)           
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

  def data_output
    save_code_to_file
    read_code_from_file            
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

  def render_view(template)
    Rack::Response.new(render(template)) do |response|       
      unless @cook
        code = (RANGE_NUMBERS).to_a.sort{ rand() - 0.5 }[ARRAY_SIZE]
        response.set_cookie('secret_code', {:value => code, :path => "/", :expires => Time.now+24*60*60})        
      end         
    end
  end
  
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end  
end