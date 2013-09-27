require './lib/cinruby'
require 'test/unit'

class TestCinruby < Test::Unit::TestCase
  def test_devuelve_inc
    assert_equal(8, Cinruby.devuelve_inc(3))
  end
end
