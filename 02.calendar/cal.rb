#! /usr/bin/env ruby

require 'date'
require 'optparse'

params = ARGV.getopts('', "y:#{Date.today.year}", "m:#{Date.today.month}")

year = params['y'].to_i
month = params['m'].to_i

last_date = Date.new(year, month, -1)
date = Date.new(year, month, 1)
month = date.month
year = date.year
wday = date.wday
day = date.day

puts "     #{month}月 #{year}"
puts '日 月 火 水 木 金 土'

if wday == 6
  print '                  '
elsif wday == 5
  print '               '
elsif wday == 4
  print '            '
elsif wday == 3
  print '         '
elsif wday == 2
  print '      '
elsif wday == 1
  print '   '
end

while last_date >= date
  if date.wday == 6
    if date.day < 10
      puts " #{date.day} "
    else
      puts "#{date.day} "
    end
  elsif date.day < 10
    print " #{date.day} "
  else
    print "#{date.day} "
  end
  date += 1
end
