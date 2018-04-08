require 'lib/build_option'
require 'lib/genome/factory'

# TODO rename     

RSpec.describe Genome::Factory do

  describe '-built random genome' do
    let(:length) { 3 }
    let(:builder) { Genome::Factory.new(build_options, length) }
    subject { builder.random_genome }

    context 'with no sub-choices' do
      let(:build_options) do
        [
          BuildOption.new('Option A'),
          BuildOption.new('Option B')
        ]
      end

      specify 'choses from the options given' do
        subject.build_choices.each do |option|
          expect(build_options).to include(option)
        end
      end

      specify 'generates a genome of the right length' do
        expect(subject.build_choices.length).to eq length
      end
    end

    context 'when a build choice has sub-choices' do
      let(:possible_effects) { ['Effect 1', 'Effect 2' ] }
      let(:sub_choices) do
        [
          BuildOption::Choice.new(' 1', [possible_effects[0]]),
          BuildOption::Choice.new(' 2', [possible_effects[1]])
        ]
      end
      let(:build_options) do
        [
          BuildOption.new('Option', [], sub_choices)
        ]
      end

      specify 'choses all necessary options' do
        subject.build_choices.each do |option|
          expect(option.effects.length).to eq 1
        end
      end

      specify 'choses effects and names from the options presented' do
        subject.build_choices.each do |option|
          name_parts = option.name.split
          expect(name_parts.first).to eq 'Option'
          expect(name_parts.last).to eq('1').or eq('2')

          if name_parts.last == '1'
            expect(option.effects).to eq ['Effect 1']
          elsif name_parts.last == '2'
            expect(option.effects).to eq ['Effect 2']
          else
            raise 'Should not reach this point because the earlier expectation would fail.'
          end
        end
      end
    end
  end
end
