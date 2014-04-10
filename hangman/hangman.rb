load 'hangman/human_player.rb'
load 'hangman/computer_player.rb'

class Hangman
  
  WORDS = File.readlines('hangman/dictionary.txt').map{|line| line.chomp}
  
  attr_accessor :secret_word, :guess, :guess_list, :body_part, :secret_word, :correct_list, :secret_word_length, :wrong_list
  
  def initialize
    puts self
    @players = [HumanPlayer.new(self), ComputerPlayer.new(self)]
    @secret_word = nil
    @body_counter = ['head', 'body', '1st arm', '2nd arm', '1st leg', '2nd leg']
    @guess = ''
    @guess_list = []
    @correct_list = []
    @wrong_list = []
  end
  
  def play
    system('clear')
    set_players
    @master_player.pick_secret_word
    @guessing_player.play
    "Thanks for playing!"
  end
  
  # computer and human classes should have same methods so that you could add another class with the same methods and the game would still play
  
  
  def secret_word=(word)
    @secret_word = word.upcase
    @secret_word_length = word.length
  end
  
  def set_players
    player_n = nil
    until player_n
      puts "Who is playing? Human = 1, Computer = 2"
      player_n = gets.chomp.scan(/\d/).first
    end
    player_n = player_n.to_i - 1
    @guessing_player = @players[player_n]
    @master_player = @players[player_n - 1]
  end

  
  def update_counters
    @guess_list << @guess
    if guess_right?
      @correct_list << @guess
    else
      @wrong_list << @guess
      @body_part = @body_counter.shift
    end
  end
  
  def guess_right?
    @secret_word.split('').include?(@guess)
  end
  
  def lost?
    @body_counter.empty?
  end 
  
  def won?
    transform_for_display == @secret_word
  end
  
  def transform_for_display
    secret = @secret_word.dup
    (@secret_word.split('') - @correct_list).each {|letter| secret.gsub!(letter, '_')}
    secret
  end
  
end


Hangman.new.play