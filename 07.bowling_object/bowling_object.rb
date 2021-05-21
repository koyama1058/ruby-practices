#!/usr/bin/env ruby

class Game
  def initialize(frames)
    @frames = frames
    @sum = frames.flatten.sum
  end

  def added_point
    @frames.each.with_index do |frame, i|
      if frame[0] == 10 && @frames[i + 1][0] == 10
        @sum += @frames[i + 1][0]
        @sum += @frames[i + 2][0]
      elsif frame[0] == 10 && @frames[i + 1][0] != 10
        @sum += @frames[i + 1][0]
        @sum += @frames[i + 1][1]
      elsif frame.sum == 10
        @sum += @frames[i + 1][0]
      end

      break if i == 8
    end
    @sum
  end
end

class Frame
  def initialize(shots)
    @shots = shots
    @frames = []
  end

  def make_frame
    @shots.each_slice(2) do |shot|
      @frames << shot
    end
    @frames
  end
end

class Shot
  def initialize(element)
    @scores = element.split(',')
    @shots = []
  end

  def make_shot
    @scores.each do |s|
      if s == 'X'
        @shots << 10 && @shots << 0
      else
        @shots << s.to_i
      end
    end
    @shots
  end
end

shots = Shot.new(ARGV[0]).make_shot
frames = Frame.new(shots).make_frame
p Game.new(frames).added_point
