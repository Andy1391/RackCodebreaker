module Codebreaker

  class User

    attr_accessor :name

    def initialize
      @name = name
      @score = 0
      @date = Time.now
    end

    def new_player
      @name = gets.chomp
      puts "Hello, " + name
    end

  end

end


