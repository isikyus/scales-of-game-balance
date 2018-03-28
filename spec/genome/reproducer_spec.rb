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

  describe '#crossover' do
    let(:left_parent) { %w[ A A A A A ] }
    let(:right_parent) { %w[ T T T T T ] }

    let(:sample_count) { 5 }
    let(:samples) do
      sample_count.times.map do
        subject.crossover(left_parent, right_parent)
      end
    end

    specify 'usually starts with the left parent' do
      first_chars = samples.map(&:first)
      expect(first_chars).to include('A', 'A', 'A', 'A')
    end

    specify 'usually ends with the right parent' do
      last_chars = samples.map(&:last)
      expect(last_chars).to include('T', 'T', 'T')
    end

    specify 'varies the point of crossover' do
      crossover_points = samples.map { |sample| sample.index('T') }
      distinct_crossover_points = crossover_points.uniq.length
      expect(distinct_crossover_points).to be > (sample_count / 2)
    end

    specify 'returns an array of the same length as the parents' do
      expect(samples.map(&:length)).to eq([left_parent.length] * sample_count)
    end

    context 'when the left parent is longer' do
      let(:left_parent) { %w[ A A A A A A ] }
      let(:right_parent) { %w[ T T T ] }

      specify 'choses a length between the two values' do
        lengths = samples.map(&:length)

        expect(lengths.max).to be <= left_parent.length
        expect(lengths.min).to be >= right_parent.length
      end
    end

    context 'when the right parent is longer' do
      let(:left_parent) { %w[ A A A ] }
      let(:right_parent) { %w[ T T T T ] }

      specify 'choses a length between the two values' do
        lengths = samples.map(&:length)

        expect(lengths.max).to be <= right_parent.length
        expect(lengths.min).to be >= left_parent.length
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
