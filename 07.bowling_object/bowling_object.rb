#!/usr/bin/env ruby
# frozen_string_literal: true

class Shot
  attr_reader :shot

  def initialize(shot)
    @shot = shot
  end

  def score
    @shot == 'X' ? 10 : @shot.to_i
  end
end

class Frame
  attr_reader :first_shot, :second_shot, :third_shot

  def initialize(first_shot, second_shot = nil, third_shot = nil)
    @first_shot = Shot.new(first_shot).score
    @second_shot = Shot.new(second_shot).score
    @third_shot = Shot.new(third_shot).score
  end

  def frame_score
    frame_point = @first_shot
    frame_point += @second_shot if @second_shot
    frame_point += @third_shot if @third_shot
    frame_point
  end

  def strike?
    @first_shot == 10
  end

  def spare?
    !strike? && @first_shot + @second_shot == 10
  end
end

class Game
  attr_reader :input, :frames

  def initialize(input)
    @input = input
  end

  def split_frame
    shots = @input.split(',')
    @frames = []
    while frames.size < 9
      shot = shots.shift
      if shot == 'X'
        frames << Frame.new(shot)
      else
        next_shot = shots.shift
        frames << Frame.new(shot, next_shot)
      end
    end
    frames << Frame.new(*shots)
    frames
  end

  def basic_score
    basic_score = 0
    split_frame.each do |frame|
      basic_score += frame.frame_score
    end
    basic_score
  end

  def bonus_score
    bonus_score = 0
    split_frame.each.with_index do |frame, i|
      # ストライクの際のボーナス
      if frame.strike? && frames[i + 1].first_shot == 10 && i != 8
        bonus_score += (frames[i + 1].first_shot + frames[i + 2].first_shot)
      elsif frame.strike? && frames[i + 1].first_shot == 10 && i == 8
        bonus_score += (frames[i + 1].first_shot + frames[i + 1].second_shot)
      elsif frame.strike? && frames[i + 1].first_shot != 10
        bonus_score += (frames[i + 1].first_shot + frames[i + 1].second_shot)
      # スペアの際のボーナス
      elsif frame.spare?
        bonus_score += frames[i + 1].first_shot
      end
      break bonus_score if i == 8
    end
  end

  def total_score
    basic_score + bonus_score
  end
end
