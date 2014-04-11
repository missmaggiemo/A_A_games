class CheckersPlayer
  
  attr_accessor :name, :color
  
  def initialize(name, color)
    @name = name
    @color = color
  end
  
  def to_s
    @name
  end
  
  def get_start_pos
    pos = []
    while pos.empty?
      puts "#{@name.capitalize}, you are #{color.to_s}. Which piece do you want to move?"
      user_pos = gets.chomp
      return :quit if user_pos.downcase.match(/q/)
      if user_pos.scan(/\d/)[0,2].length == 2
        pos = user_pos.scan(/\d/)[0,2].map{|n| n.to_i - 1}
      else
        puts "Position not valid."
      end
    end
    pos
  end
  
  def get_end_pos
    pos = []
    while pos.empty?
      puts "Where do you want to put it?"
      user_pos = gets.chomp
      return :quit if user_pos.downcase.match(/q/)
      if user_pos.scan(/\d/)[0,2].length == 2
        pos = user_pos.scan(/\d/)[0,2].map{|n| n.to_i - 1}
      else
        puts "Position not valid."
      end
    end
    pos
  end
  

end