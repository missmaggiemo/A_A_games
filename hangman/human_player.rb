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
    @game.guess = ''
    while @game.guess.empty?
      puts "Word: #{@game.transform_for_display.split('').join(' ')}"
      puts "Guess list: #{@game.guess_list}"
      puts "Guess?"
      user_guess = gets.chomp.upcase
      if user_guess.match(/[A-Z]/) && !@game.guess_list.include?(user_guess)
        @game.guess = user_guess
      elsif user_guess == 'QUIT'
        @game.guess = user_guess
      end
      puts("Please guess again.") if @game.guess.empty?
    end
  end
  
  def quit?
    @game.guess == 'QUIT'
  end
  
  def normalize_guess
    @game.guess = @game.guess.upcase[0]
  end
  
  def feedback
    if @game.guess_right?
      puts "Yay! #{@game.guess} is in the secret word!\n\n"
      puts "You win! The secret word was #{@game.secret_word}." if @game.won?
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