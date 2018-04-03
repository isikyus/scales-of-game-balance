require 'lib/parser'
require 'stringio'

RSpec.describe Parser do

  let(:parser) { Parser.new(StringIO.new(data)) }

  describe 'a parsed constraint' do

    let(:data) do
      %q{
resources:
  - name: ability_score_points_spent
    maximum: 15
      }
    end

    let(:parsed_constraints) { parser.constraints }
    subject { parsed_constraints.first }

    specify 'has the correct resource' do
      expect(subject.resource).to eq 'ability_score_points_spent'
    end

    describe 'representing actual constraints' do

      specify 'has its maximum' do
        expect(subject.limits[:maximum]).to eq 15
      end
    end
  end

  shared_examples_for 'strength point buy' do

    let(:parsed_options) { parser.build_options }
    subject { parsed_options.first }

    specify 'has the correct name' do
      expect(subject.name).to eq 'Strength Point Buy'
    end

    describe 'sub-choices' do
      let(:choices) { subject.choices }

      specify 'exist for each choice in the data' do
        expect(choices.length).to eq 2
      end

      specify 'include name suffixes' do
        expect(choices.first.name_suffix).to eq '(7)'
        expect(choices.last.name_suffix).to eq '(8)'
      end

      describe 'effects' do
        let(:str_7_effects) { choices.first.effects }
        let(:points_effect) do
          str_7_effects.detect do |e|
            e.resource == 'ability_score_points_spent'
          end
        end
        let(:str_effect) do
          str_7_effects.detect { |e| e.resource == 'STR_score' }
        end

        specify 'are all parsed' do
          expect(str_7_effects.length).to eq 2
        end

        specify 'are created for stat changes' do
          expect(points_effect).to be_a Effect::Change
          expect(points_effect.change).to eq(-4)
        end

        specify 'are created to set values' do
          expect(str_effect).to be_a Effect::SetValue
          expect(str_effect.value_to_set).to eq 7
        end
      end
    end
  end

  describe 'a parsed build option' do
    let(:data) do
      %q{
build_options:
  - name: Strength Point Buy
    multiple: no
    choices:
      - name_suffix: (7)
        effects:
          - resource: ability_score_points_spent
            change: -4
          - statistic: STR_score
            value: 7
      - name_suffix: (8)
        effects:
          - resource: ability_score_points_spent
            change: -2
          - statistic: STR_score
            value: 8
      }
    end

    it_should_behave_like 'strength point buy'
  end

  describe 'a build option using tables' do
    let(:data) do
      %q{
tables:
  - name: Ability Score Point Buy
    id: ability-score-point-buy
    parameters:
    - $stat
    rows:
    - name_suffix: (7)
      effects:
      - resource: ability_score_points_spent
        change: -4
      - resource: $stat
        value: 7
    - name_suffix: (8)
      effects:
      - resource: ability_score_points_spent
        change: -2
      - resource: $stat
        value: 8

build_options:
  - name: Strength Point Buy
    multiple: no
    choices_from_table:
      table: ability-score-point-buy
      $stat: STR_score
      }
    end

    it_should_behave_like 'strength point buy'
  end

  describe 'an option that cannot be taken multiple times' do
    let(:data) do
      %q{
build_options:
- name: Once-off Boost
  once-only: true
  effects:
  - resource: ability_score_points_spent
    change: +2
      }
    end

    describe 'build option' do
      subject { parser.build_options.first }

      specify 'has the correct name' do
        expect(subject.name).to eq 'Once-off Boost'
      end

      describe 'effects' do
        let(:points_effect) do
          subject.effects.detect { |e| e.resource == 'ability_score_points_spent' }
        end
        let(:implied_effect) do
          subject.effects.detect { |e| e.resource == 'once-off-boost#count' }
        end

        specify 'has the stated effect' do
          expect(points_effect).to be_a Effect::Change
          expect(points_effect.change).to eq(+2)
        end

        specify 'consumes the implied resource' do
          expect(implied_effect).to be_a Effect::Change
          expect(implied_effect.change).to eq(+1)
        end
      end
    end

    describe 'implied constraints' do

      let(:implied_constraints) { parser.constraints }
      subject { implied_constraints.first }

      specify 'are created for the implied resource' do
        expect(subject.resource).to eq 'once-off-boost#count'
        expect(subject.limits[:maximum]).to eq 1
      end
    end
  end
end
