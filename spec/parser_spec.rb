require 'lib/parser'
require 'stringio'

RSpec.describe Parser do

  let(:parser) { Parser.new(StringIO.new(data)) }

  describe 'a parsed constraint' do

    let(:data) do
      %q{
resources:
  - name: ability_score_points_spent
    # "Standard Fantasy" point buy limit.
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

  describe 'parsing build options' do
  end
end
