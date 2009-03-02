require 'runit/testcase'
require 'runit/cui/testrunner'
require 'runit/testsuite'
require 'diff'
require 'test_cases'

class UnixDiffTest < RUNIT::TestCase

  include DiffArrayTests
  #include DiffStressTest

  def makefile(filename, ary)
    File.open(filename, "w") { |f|
      ary.each { |elem|
        f.puts elem.to_s
      }
    }
  end

  def rundiff(prog)
    res = []
    IO.popen("#{prog} file1 file2") { |f|
      while ln = f.gets 
        res << ln
      end
    }
    res
  end

  def difftest(a, b)
    makefile("file1", a)
    makefile("file2", b)
    result1 = rundiff("diff")
    result2 = rundiff("./unixdiff.rb");
    assert_equal(result1, result2)
  end
end

RUNIT::CUI::TestRunner.run(UnixDiffTest.suite)
