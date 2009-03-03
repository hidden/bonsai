#!/usr/bin/env ruby

require 'diff'

# TODO: parameters


def loadfile(filename)
  lines = nil
  File.open(filename, "r") { |f|
    lines = f.readlines
  }
  return lines
end

def diffrange(a, b)
  if (a == b)
    "#{a}"
  else
    "#{a},#{b}"
  end
end

class Diff
  def to_diff(io = $defout)
    offset = 0
    @diffs.each { |b|
      first = b[0][1]
      length = b.length
      action = b[0][0]
      addcount = 0
      remcount = 0
      b.each { |l| 
        if l[0] == "+"
          addcount += 1
        elsif l[0] == "-"
          remcount += 1
        end
      }
      if addcount == 0
        puts "#{diffrange(first+1, first+remcount)}d#{first+offset}"
      elsif remcount == 0
        puts "#{first-offset}a#{diffrange(first+1, first+addcount)}"
      else
        puts "#{diffrange(first+1, first+remcount)}c#{diffrange(first+offset+1, first+offset+addcount)}"
      end
      lastdel = (b[0][0] == "-")
      b.each { |l|
        if l[0] == "-"
          offset -= 1
          print "< "
        elsif l[0] == "+"
          offset += 1
	  if lastdel
	    lastdel = false
            puts "---"
          end
          print "> "
        end
	print l[2]
      }
    }
  end
end

if $0 == __FILE__

  file1 = ARGV.shift
  file2 = ARGV.shift

  ary1 = loadfile file1
  ary2 = loadfile file2

  diff = Diff.new(ary1, ary2)
  diff.to_diff

end
