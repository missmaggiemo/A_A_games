class HumanPlayer
  
  attr_reader :is_human
  
  def initialize(game)
    @is_human = true
    @game = game
  end
  
  def play
    loop do
      get_guess
      break if quit?
      normalize_guess
      @game.update_counters
      feedback
      break if @game.won? || @game.lost?
    end
  end
  
  
  
  
  def get_guess
    puts "Word: #{@game.transform_for_display}"
    puts "Guess list: #{@game.guess_list}"
    puts "Guess?"
    @game.guess = gets.chomp
  end
  
  def quit?
    @game.guess.downcase == 'quit'
  end
  
  def normalize_guess
    @game.guess = @game.guess.upcase[0]
  end
  
  def feedback
    if @game.guess_right?
      puts "Yay! #{@game.guess} is in the secret word!\n\n"
    else
      puts "Oh no! You guessed wrong. We have to draw your #{@game.body_part}.\n\n"
      puts "Sorry, the hangman died! You lose. Word was #{@game.secret_word}.\n\n" if @game.lost?
    end
  end
  
  def pick_secret_word
    until @game.secret_word
      puts "Please enter a word for the computer to guess:"
      user_response = gets.chomp.scan(/\w+/).first.downcase
      Hangman::WORDS.include?(user_response) ? @game.secret_word = user_response.upcase : puts("That wasn't a valid word!")
    end
  end
  
end