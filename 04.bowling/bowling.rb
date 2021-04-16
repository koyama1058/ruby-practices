#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')
shots = []

scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

sum = shots.sum

frames = []
shots.each_slice(2) do |shot|
  frames << shot
end

frames.each.with_index do |frame, i|
  if frame[0] == 10
    if frames[i + 1][0] != 10
      sum += frames[i + 1][0]
      sum += frames[i + 1][1]
    else
      sum += frames[i + 1][0]
      sum += frames[i + 2][0]
    end
  elsif frame.sum == 10
    sum += frames[i + 1][0]
  end

  break if i == 8
end

puts sum
