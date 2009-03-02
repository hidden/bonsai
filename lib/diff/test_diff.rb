require 'runit/testcase'
require 'runit/cui/testrunner'
require 'runit/testsuite'
require 'diff'
require 'test_cases'

class DiffTest < RUNIT::TestCase

  include DiffStringTests
  include DiffArrayTests
  include DiffStressTest

  def difftest(a, b)
    diff = Diff.new(a, b)
    c = a.patch(diff)
    assert_equal(b, c)
    diff = Diff.new(b, a)
    c = b.patch(diff)
    assert_equal(a, c)
  end

end

RUNIT::CUI::TestRunner.run(DiffTest.suite)
