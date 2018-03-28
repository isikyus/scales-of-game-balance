
# Simple random name generator to make characters more identifiable.

class NameGenerator

  # Tables used to generate names.
  # TODO: extract to a data file:
  INITIALS = ['', 'h', 'l', 'r', 'w', 'y', 'v', 'z', 'j']
  VOWELS = ['a', 'e', 'i', 'o', 'u', 'o', 'u', 'ah', 'oh', 'uh']
  FINALS = ['b', 'c', 'd', 'g', 'k', 'p', 'q', 't', 'x', 'gg', 'kk']

  def initialize(random = Random.new, initials=INITIALS, vowels=VOWELS, finals=FINALS)
    @random = random
    @initials = initials
    @vowels = vowels
    @finals = finals
  end

  # @return [String]
  def call
    length = 1 + rand(3)
    lower_case_name = length.times.map { random_syllable }.join
    upcase_first(lower_case_name)
  end

  private

  # @return [String]
  def random_syllable
    syllable = ''
    syllable << sample_from_array(INITIALS)
    syllable << sample_from_array(VOWELS)
    syllable << sample_from_array(FINALS)
    syllable
  end

  # @param array [Array]
  def sample_from_array(array)
    index = @random.rand(array.length)
    array[index]
  end

  # Upper-case the first letter of a word.
  # @param text [String]
  # @return [String]
  def upcase_first(text)
    text.sub(/[[:lower:]]/) { |initial| initial.upcase }
  end
end
