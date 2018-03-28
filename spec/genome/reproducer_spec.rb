require 'lib/genome/reproducer'

RSpec.describe Genome::Reproducer do

  let(:build_options) { %w[ A C G T ] }
  let(:name_generator) { double('NameGenerator') }
  let(:character_factory) { double('CharacterFactory') }
  let(:mutation_chance) { 0.1 }
  subject do
    Genome::Reproducer.new(build_options, mutation_chance)
  end

  describe '#mutate' do
    let(:genome) { double(Genome, :build_choices => %w[ G C A G T ]) }

    before do
      # Since we stub out apply_mutation!,
      # the new genome should always be a copy of the old.
      allow(Genome).to receive(:new).with(genome.build_choices)
    end

    specify 'returns a new genome' do
      expect(Genome).to receive(:new).
                          with(genome.build_choices).
                          and_return(:new_genome)
      expect(subject.send(:mutate, genome)).to eq :new_genome
    end

    context 'with zero mutation rate' do
      let(:mutation_chance) { 0 }

      specify 'does not apply mutations' do
        expect(subject).not_to receive(:apply_mutation!)
        subject.send(:mutate, genome)
      end
    end

    context 'with high mutation chance' do
      let(:mutation_chance) { 0.8 }

      specify 'usually applies mutations' do
        expect(subject).to receive(:apply_mutation!).
                              with(genome.build_choices).
                              at_least(2).times

        4.times do
          subject.send(:mutate, genome)
        end
      end
    end

    context 'with very high mutation chance' do
      let(:mutation_chance) { 1 }

      specify 'still terminates' do
        allow(subject).to receive(:apply_mutation!).
                              with(genome.build_choices).
                              at_least(2).times

        expect do
          Timeout.timeout(1) do
            subject.send(:mutate, genome)
          end
        end.not_to raise_error
      end
    end
  end
end
