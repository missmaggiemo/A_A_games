load 'poker/lib/poker_card.rb'

class PokerDeck
  attr_accessor :cards

  def self.all_cards
    cards = []
    PokerCard.suits.each do |suit|
      PokerCard.values.each do |value|
        cards << PokerCard.new(suit, value)
      end
    end
    cards
  end

  def initialize(cards = nil)
    @cards = cards || PokerDeck.all_cards
  end

  def take(num_cards)
    @cards.shift(num_cards)
  end

  def return(cards)
    @cards += cards
  end

  def shuffle
    @cards.shuffle!
  end

end