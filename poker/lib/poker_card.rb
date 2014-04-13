require 'colorize'

# -*- coding: utf-8 -*-

# Represents a playing card.
class PokerCard
  SUIT_STRINGS = {
    :clubs    => "♣",
    :diamonds => "♦",
    :hearts   => "♥",
    :spades   => "♠"
  }

  VALUE_STRINGS = {
    :deuce => "2",
    :three => "3",
    :four  => "4",
    :five  => "5",
    :six   => "6",
    :seven => "7",
    :eight => "8",
    :nine  => "9",
    :ten   => "10",
    :jack  => "J",
    :queen => "Q",
    :king  => "K",
    :ace   => "A"
  }

  POKER_VALUE = {
    :deuce => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 11,
    :queen => 12,
    :king  => 13,
    :ace => 14
  }

  # aces are weird! 1 or 14

  # Returns an array of all suits.
  def self.suits
    SUIT_STRINGS.keys
  end

  # Returns an array of all values.
  def self.values
    VALUE_STRINGS.keys
  end

  attr_reader :suit, :value, :poker_value

  def initialize(suit, value)
    unless PokerCard.suits.include?(suit) and PokerCard.values.include?(value)
      raise "illegal suit (#{suit}) or value (#{value})"
    end

    @suit, @value = suit, value
    @poker_value = POKER_VALUE[value]
  end

  # Compares two cards to see if they're equal in poker value-- number value only, ace = 14.
  
  # == method is used in 'delete'
  
  def ==(other_card)
    return false if other_card.nil?
    self.suit == other_card.suit && self.value == other_card.value
  end

  def >(other_card)
    return false if other_card.nil?
    self.poker_value > other_card.poker_value
  end

  def <(other_card)
    return false if other_card.nil?
    self.poker_value < other_card.poker_value
  end
  

  def to_s
    if [:diamonds, :hearts].include?(suit)
      (VALUE_STRINGS[value] + SUIT_STRINGS[suit]).colorize(:red)
    else
      (VALUE_STRINGS[value] + SUIT_STRINGS[suit]).colorize(:black)
    end
  end
  
end