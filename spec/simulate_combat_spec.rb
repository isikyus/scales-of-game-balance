require 'lib/simulate_combat'

RSpec.describe SimulateCombat do

	describe "simulating one turn" do

		it 'has the active character choose an action'
		it 'calculates the effect of that action'
		it 'generates an event with the action and its effect'
	end

	describe 'simulating a round' do

		it 'simulates a turn for each character'
	end

	describe 'simulating a full combat' do

		it 'determines initiative'
		it 'simulates rounds until the outcome is clear'
		it 'generates an event describing the outcome'
	end
end
