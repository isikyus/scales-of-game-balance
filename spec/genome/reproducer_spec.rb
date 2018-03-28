require 'lib/genome/reproducer'

RSpec.describe Genome::Reproducer do

  let(:build_options) { %w[ A C G T ] }
  let(:name_generator) { double('NameGenerator') }
  let(:character_factory) { double('CharacterFactory') }
  let(:mutation_chance) { 0.1 }
  subject do
    Genome::Reproducer.new(build_options, mutation_chance)
  end

  let(:build_choices) { %w[ G C A G T ] }
  let(:genome) { double(Genome, :build_choices => build_choices) }

  describe '#child' do

    context 'without mutation or crossover' do
      let(:mutation_chance) { 0 }

      specify 'builds a new genome based on the input' do
        expect(Genome).to receive(:new).
                            with(build_choices).
                            and_return(:new_genome)

        expect(subject.send(:child, genome, genome)).to eq :new_genome
      end
    end
  end

  describe '#mutate' do
    context 'with zero mutation rate' do
      let(:mutation_chance) { 0 }

      specify 'does not apply mutations' do
        expect(subject).not_to receive(:apply_mutation!)
        subject.send(:mutate, build_choices)
      end
    end

    context 'with high mutation chance' do
      let(:mutation_chance) { 0.8 }

      specify 'usually applies mutations' do
        expect(subject).to receive(:apply_mutation!).
                              with(build_choices).
                              at_least(2).times

        4.times do
          subject.send(:mutate, build_choices)
        end
      end
    end

    context 'with very high mutation chance' do
      let(:mutation_chance) { 1 }

      specify 'still terminates' do
        allow(subject).to receive(:apply_mutation!).
                              with(build_choices).
                              at_least(2).times

        expect do
          Timeout.timeout(1) do
            subject.send(:mutate, build_choices)
          end
        end.not_to raise_error
      end
    end
  end
end
