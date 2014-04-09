class ComputerPlayer  
  
  attr_reader :is_human
  
  def initialize(game)
    @is_human = false
    @game = game
    @viable_words = Hangman::WORDS.dup
  end
  
  def play
    loop do
      update_word_list
      update_letter_list
      get_guess
      @game.update_counters
      feedback
      break if @game.won? || @game.lost?
    end
  end
  
  
  
  def get_guess
    puts "Word: #{@game.transform_for_display}"
    @game.guess = @viable_letters.shift
    puts "Computer guess: #{@game.guess}"
  end

  def update_word_list
    display = @game.transform_for_display
    if @game.guess_list.empty?
      select_words_via_length
    else
      select_words_via_placement(display)
    end
  end
  
  def select_words_via_length
    @viable_words.select! {|word| word.length == @game.secret_word.length}
  end
  
  def select_words_via_placement(placement)
    @viable_words.select! do |word| 
      word.upcase.split('').map.with_index do |letter, letter_i|
         placement[letter_i] == letter || placement[letter_i] == '_'
      end.all?
    end
  end
  
  def update_letter_list
    letters = @viable_words.join('').upcase.split('') - @game.guess_list
    frequency = letters.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    @viable_letters = letters.sort_by{|v| -frequency[v]}.uniq
  end
  
  
  def feedback
    if @game.guess_right?
      puts "Good job, computer! #{@game.guess} is in the secret word!\n\n"
    else
      puts "The computer guessed wrong. We have to draw the computer's #{@game.body_part}.\n\n"
      puts "Sorry, the hangman died! Computer loses.\n\n" if @game.lost?
    end
  end
  
  def pick_secret_word
    @game.secret_word = Hangman::WORDS.sample.upcase
  end
  
  # def transform_for_display
#     secret = @game.secret_word.dup
#     (@game.secret_word.split('') - @game.correct_list).each {|letter| secret.gsub!(letter, '_')}
#     secret
#   end
#   
end