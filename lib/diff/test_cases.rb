module DiffArrayTests

  def test_array_append
    difftest [1,2,3], [1,2,3,4]
    difftest [1,2,3], [1,2,3,4,5]
  end

  def test_array_prepend
    difftest [1,2,3], [0,1,2,3]
    difftest [1,2,3], [-1,0,1,2,3]
  end

  def test_array_insert
    difftest [1,2,3], [1,2,4,3]
    difftest [1,2,3], [1,2,4,5,3]
  end

  def test_array_remove
    difftest [1,2,3], [1,3]
  end

  def test_array_cutfront
    difftest [1,2,3], [2,3]
    difftest [1,2,3], [3]
  end

  def test_array_cutback
    difftest [1,2,3], [1,2]
    difftest [1,2,3], [1]
  end

  def test_array_empty
    difftest [1,2,3], []
  end

  def test_array_fill
    difftest [], [1,2,3]
  end

  def test_array_change
    difftest [1,2,3], [1,4,3]
    difftest [1,2,3], [1,4,5]
    difftest [1,2,3,4], [1,5,4]
  end

  def test_array_noop
    difftest [1,2,3], [1,2,3]
  end

  def test_array_grow
    difftest [1,2,3], [4,1,5,2,6,3,7]
  end

  def test_array_shrink
    difftest [1,2,3,4,5,6,7], [2,4,6]
  end

end

module DiffStringTests

  def test_string_append
    difftest "abc", "abcd"
    difftest "abc", "abcde"
  end

  def test_string_preprend
    difftest "abc", "qabc"
    difftest "abc", "qrabc"
  end
  
  def test_string_insert
    difftest "abc", "abqc"
    difftest "abc", "abqrc"
  end
  
  def test_string_cutfront
    difftest "abc", "bc"
    difftest "abc", "c"
  end

  def test_string_cutback
    difftest "abc", "ab"
    difftest "abc", "a"
  end

  def test_string_empty
    difftest "abc", ""
  end
  
  def test_string_fill
    difftest "", "abc"
  end

  def test_string_change
    difftest "abc", "aqc"
    difftest "abc", "aqrc"
    difftest "abcd", "aqd"
  end

  def test_string_noop
    difftest "abc", "abc"
  end

  def test_string_grow
    difftest "abc", "qarbsct"
  end
  
  def test_string_shrink
    difftest "abcdefg", "bdf"
  end

  def test_string_remove
    difftest "abc", "ac"
  end

end

module DiffStressTest
  Elems = [1,2,3]
  def generate_array
    length = (16 + 16 * rand).to_i
    ary = []
    length.times {
      ary << Elems[(rand * Elems.length).to_i]
    }
    return ary
  end

  def test_stress
    256.times {
      a = generate_array
      b = generate_array
      difftest(a, b)
    }
  end
end
