require 'poker_hand'
require 'rspec'

describe PokerHand do

  let(:cards) do
    cards = [
      PokerCard.new(:hearts, :ace),
      PokerCard.new(:clubs, :three),
      PokerCard.new(:hearts, :king),
      PokerCard.new(:diamonds, :king),
      PokerCard.new(:clubs, :five),
      PokerCard.new(:diamonds, :three),
      PokerCard.new(:hearts, :five)
    ]
  end

  let(:deck) {PokerDeck.new(cards.dup)}

  subject(:hand) {PokerHand.new(deck.take(5), deck)}

  describe '#cards' do
    it { expect(hand.cards).to eq(cards[0..4]) }
  end

  # add cards to the hand, take cards from the hand(by index??)
  describe '#discard' do
    it 'removes specific cards from hand via index' do
      expect(hand.discard([0,1,2])).to eq(cards[0..2])
    end

    it 'raises an error when trying to discard more than 3 cards' do
      expect {
        hand.discard([0,1,2,3])
      }.to raise_exception 'Cannot discard more than 3 cards'
    end
  end

  describe '#add_cards' do
    it 'raises an exception when adding cards would result in 5+ card hand' do
      expect {
        hand.add_cards(cards[0..1])
      }.to raise_exception "Maximum cards in hand is 5"
    end

    it 'should add cards to the hand' do
      hand.discard([0,1])
      hand.add_cards([PokerCard.new(:hearts, :ace)])
      expect(hand.cards.count).to eq(4)
    end
  end

  let(:full_house_hand) {PokerHand.new([
    PokerCard.new(:hearts, :ace),
    PokerCard.new(:clubs, :ace),
    PokerCard.new(:hearts, :king),
    PokerCard.new(:diamonds, :king),
    PokerCard.new(:diamonds, :ace)
  ])}

  let(:straight_flush_hand) {PokerHand.new([
    PokerCard.new(:hearts, :ace),
    PokerCard.new(:hearts, :deuce),
    PokerCard.new(:hearts, :three),
    PokerCard.new(:hearts, :four),
    PokerCard.new(:hearts, :five)
  ])}

  let(:quad_hand) {PokerHand.new([
    PokerCard.new(:hearts, :ace),
    PokerCard.new(:diamonds, :ace),
    PokerCard.new(:spades, :ace),
    PokerCard.new(:clubs, :ace),
    PokerCard.new(:hearts, :five)
  ])}

  let(:two_pair_hand) {PokerHand.new([
    PokerCard.new(:hearts, :ace),
    PokerCard.new(:clubs, :ace),
    PokerCard.new(:hearts, :king),
    PokerCard.new(:diamonds, :king),
    PokerCard.new(:diamonds, :deuce)
  ])}

  let(:other_two_pair_hand) {PokerHand.new([
    PokerCard.new(:hearts, :deuce),
    PokerCard.new(:clubs, :ace),
    PokerCard.new(:hearts, :king),
    PokerCard.new(:diamonds, :king),
    PokerCard.new(:diamonds, :deuce)
  ])}


  describe 'find poker subsets' do

    describe '#find_pair' do
      it "finds a pair in a poker hand" do
        full_house_hand.update_hand_hash
        expect(full_house_hand.find_pair).to be_true
      end
    end

    describe '#find_triple' do
      it "finds a triple in a poker hand" do
        full_house_hand.update_hand_hash
        expect(full_house_hand.find_triple).to be_true
      end
    end

    describe '#find_quad' do
      it "finds a quadruple in a poker hand" do
        quad_hand.update_hand_hash
        expect(quad_hand.find_quad).to be_true
      end
    end

    describe '#find_straight' do
      it "finds a straight in a poker hand" do
        straight_flush_hand.update_hand_hash
        expect(straight_flush_hand.find_straight).to be_true
      end
    end

    describe '#find_flush' do
      it "finds a flush in a poker hand" do
        straight_flush_hand.update_hand_hash
        expect(straight_flush_hand.find_flush).to be_true
      end
    end

    describe '#find_full_house' do
      it "finds a full house in a poker hand" do
        full_house_hand.update_hand_hash
        expect(full_house_hand.find_full_house).to be_true
      end
    end

    describe '#find_straight_flush' do
      it "finds a straight flush in a poker hand" do
        straight_flush_hand.update_hand_hash
        expect(straight_flush_hand.find_straight_flush).to be_true
      end
    end

    describe '#find_two_pair' do
      it "finds two of a kind" do
        two_pair_hand.update_hand_hash
        expect(two_pair_hand.find_two_pair).to be_true
      end
    end

    describe '#find_high_card' do
      it 'finds highest card of a card array' do
        hand.update_hand_hash
        expect(hand.find_high_card(cards)).to eq(cards[0])
      end
    end

    describe '#find_poker_subsets' do
      it 'does not return a wrong hand value' do
        expect(full_house_hand.find_poker_subsets).to eq(6)
      end
    end

  end

  describe 'compare poker hands' do

    describe '#>' do
      it 'returns true when a higher hand is compared with a lower hand' do
        expect(straight_flush_hand > two_pair_hand).to be_true
      end

      it 'returns false when a lower hand is compared with a higher hand' do
        expect(two_pair_hand > straight_flush_hand).to be_false
      end
    end

    describe '#<' do
      it 'returns false when a higher hand is compared with a lower hand' do
        expect(straight_flush_hand < two_pair_hand).to be_false
      end

      it 'returns true when a lower hand is compared with a higher hand' do
        expect(two_pair_hand < straight_flush_hand).to be_true
      end
    end

    describe '#==' do
      it 'returns true when a hands of the same value are compared' do
        expect(two_pair_hand == other_two_pair_hand).to be_true
      end

      it 'returns false when a hands of different values are compared' do
        expect(straight_flush_hand == two_pair_hand).to be_false
      end
    end

  end

  # handle ties-- strict tie (hands are completely equal) or 'next steps' (highest subset is equal)-- or eliminate the need for ties?























end