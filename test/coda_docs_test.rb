require "test_helper"

class CodaDocsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CodaDocs::VERSION
  end
end
