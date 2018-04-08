require 'lib/run_generation'

RSpec.describe RunGeneration do

  let(:population) { ['p', 'Z', 'x', 'A', 'z', 'Y', '?'] }

  # Favour characters earlier in the alphabet.
  class DowncaseScorer
    def score(character)
      character.downcase
    end
  end

  let(:reproducer) { double('Reproducer') }
  subject { RunGeneration.new(DowncaseScorer.new, reproducer, survival_rate) }


  describe 'with a low survival rate' do
    let(:survival_rate) { 2.0 / population.length }

    specify 'keeps few individuals' do
      allow(reproducer).to receive(:child).at_least(:once)
      expect(subject.call(population)).to include('z', 'Z')
    end

    specify 'preserves the population size' do
      allow(reproducer).to receive(:child).at_least(:once)
      expect(subject.call(population).length).to eq population.length
    end

    specify 'creates new characters descended from the fittest' do

      # Only four legal pairings to use.
      expect(reproducer).to receive(:child).with('Z', 'z').at_least(:once)
      expect(reproducer).to receive(:child).with('z', 'Z').at_least(:once)
      expect(reproducer).to receive(:child).with('Z', 'Z').at_least(:once)
      expect(reproducer).to receive(:child).with('z', 'z').at_least(:once)

      # Use a much larger population to ensure we get all possible combinations.
      subject.call(population * 4)
    end
  end

  describe 'with a high survival rate' do
    let(:survival_rate) { 4.0 / population.length }

    specify 'keeps more individuals' do
      allow(reproducer).to receive(:child).at_least(:once)
      expect(subject.call(population)).to include('z', 'Z', 'x', 'Y')
    end
  end

  describe 'when all individuals survive' do
    let(:survival_rate) { 1 }

    specify 'does not create any descendants' do
      expect(reproducer).not_to receive(:child)
      expect(subject.call(population).to_set).to eq(population.to_set)
    end
  end

  describe 'when no individuals survive' do
    let(:survival_rate) { 0.000001 }

    specify 'reports an error' do
      expect do
        subject.call(population)
      end.to raise_error(RunGeneration::ExtinctionError)
    end
  end

  describe 'when only one individual survives' do
    let(:population_with_clear_best) { population - ['z'] }
    let(:survival_rate) { 1.0 / population_with_clear_best.length }

    specify 'bases all descendants on that one individual' do
      expect(reproducer).to receive(:child).
                              with('Z', 'Z').
                              and_return('ZZ').
                              exactly(population_with_clear_best.length - 1).times

      descendants = subject.call(population_with_clear_best)
      expect(descendants.to_set).to eq Set.new(['Z', 'ZZ'])
    end
  end

  pending 'when multiple individuals have the same score'
end
