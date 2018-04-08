require 'lib/character_factory'
require 'lib/build_option'
require 'lib/effect'

RSpec.describe CharacterFactory do

  subject { CharacterFactory.new(constraints) }

  describe 'calculating new stats' do
    let(:genome) do
      double('Genome', :build_choices => [
        BuildOption.new('A = 1',
                        [
                          Effect::SetValue.new('A', 1),
                          Effect::Change.new('actions', 1)
                        ]),
        BuildOption.new('B = 1',
                        [
                          Effect::SetValue.new('B', 1),
                          Effect::Change.new('actions', 1)
                        ]),
        BuildOption.new('Useless = 1 (not an action)',
                        [
                          Effect::SetValue.new('useless', 1)
                        ])
      ])
    end

    let(:calculated_stats) do
      subject.build_character(genome, '').stats
    end

    context 'with enough resources' do
      let(:constraints) do
        [
          Constraint.new('actions', maximum: 3)
        ]
      end

      specify 'applies effects' do
        expect(calculated_stats).to include('A' => 1, 'B' => 1, 'useless' => 1)
      end

      specify 'consumes resources' do
        expect(calculated_stats).to include('actions' => 2)
      end
    end

    context 'when a resource runs out' do
      let(:constraints) do
        [
          Constraint.new('actions', maximum: 1)
        ]
      end

      specify 'stops applying effects that need it' do
        expect(calculated_stats).not_to include('B' => 1)
        expect(calculated_stats).to include('A' => 1, 'useless' => 1)
      end

      specify 'consumes resources up to the limit' do
        expect(calculated_stats).to include('actions' => 1)
      end

      specify 'uses default values for stats not set by effects' do
        
      end
    end
  end
end
