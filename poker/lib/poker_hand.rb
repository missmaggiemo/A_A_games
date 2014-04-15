load 'poker/lib/poker_card.rb'
load 'poker/lib/poker_deck.rb'

class PokerHand

  attr_reader :cards

  def initialize(cards=[], deck=nil)
    @cards = cards
    @deck = deck
    @hand_hash = Hash.new(0)
  end
  
  def to_s
    @cards.map {|card| card.to_s}.join('  ')
  end
  
  def length
    @cards.count
  end
  
  
  def return_cards
    @deck.return(@cards)
  end


  def discard(card_index_array)
    raise 'Cannot discard more than 3 cards' if card_index_array.count > 3
    cards = @cards.dup
    discarded = []
    card_index_array.each do |i|
      discarded << @cards.delete(cards[i])
    end
    @deck.return(discarded)
    discarded
  end


  def add_cards(card_array)
    raise "Maximum cards in hand is 5" if @cards.count + card_array.count > 5
    @cards += card_array
  end


  # list of poker hands?

  # separate method for each type of poke hand subset?

  def find_poker_subsets
    # calls other poker subset methods
    update_hand_hash
    return 8 if find_straight_flush
    return 7 if find_quad
    return 6 if find_full_house
    return 5 if find_flush
    return 4 if find_straight
    return 3 if find_triple
    return 2 if find_two_pair
    return 1 if find_pair
    return 0 if find_high_card(@cards)
  end

  def update_hand_hash
    @hand_hash = Hash.new(0)
    @cards.each do |card|
      @hand_hash[card.value] += 1
    end
  end

  def find_high_card(card_array)
    card_array.max_by { |card| card.poker_value }
  end

  # if the hand subset is found, each method returns true

  def find_pair
    @hand_hash.values.any? { |value| value == 2 }
  end


  def find_triple
    @hand_hash.values.any? { |value| value == 3 }
  end

  def find_quad
    @hand_hash.values.any? { |value| value == 4 }
  end

  def find_straight
    if @hand_hash.keys.include?(:ace)
      if @hand_hash.keys.include?(:king)
        values_list = generate_value_list
      else
        values_list =generate_value_list(ace_one=true)
      end
    else
      values_list = generate_value_list
    end
    return values_list == (values_list.first..values_list.last).to_a
  end

  def generate_value_list(ace_one=false)
    values_list = []
    @cards.each do |card|
      if ace_one && card.value == :ace
        values_list << 1
      else
        values_list << card.poker_value
      end
    end
    values_list.sort
  end

  def find_flush
    @cards.all? { |card| card.suit == @cards.first.suit }
  end

  def find_full_house
    @hand_hash.values.any? { |value| value == 2 } && @hand_hash.values.any? { |value| value == 3 }
  end

  def find_straight_flush
    find_flush && find_straight
  end

  def find_two_pair
    pair_count = 0
    @hand_hash.each { |key,value| pair_count += 1 if value == 2 }
    return true if pair_count == 2
    false
  end
  
  # find specific cards for tie-breaker comparison
  
  def find_pair_card
    @hand_hash.each do |key, value| 
      if value == 2
        @cards.each {|card| return card if card.value == key}
      end
    end
  end
  
  def find_two_pair_cards
    # returns array of two pair cards []
    pair_cards = []
    @hand_hash.each do |key, value| 
      if value == 2
        @cards.each {|card| pair_cards << card if card.value == key}
      end
    end
    pair_cards
  end
  
  def find_triple_card
    @hand_hash.each do |key, value| 
      if value == 3
        @cards.each {|card| return card if card.value == key}
      end
    end
  end
  
  def find_quad_card
    @hand_hash.each do |key, value| 
      if value == 4
        @cards.each {|card| return card if card.value == key}
      end
    end
  end

  def >(other_hand)
    self.find_poker_subsets > other_hand.find_poker_subsets
  end

  def <(other_hand)
    self.find_poker_subsets < other_hand.find_poker_subsets
  end

  # need to handle ties
  
  def ==(other_hand)
    self.find_poker_subsets == other_hand.find_poker_subsets
  end
  
  
  
  
  # write spec for this
  def sort
    @cards.sort_by {|card| card.poker_value}
  end
  
  def sort!
    @cards = @cards.sort_by {|card| card.poker_value}
  end


end