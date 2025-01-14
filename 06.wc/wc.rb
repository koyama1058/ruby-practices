#!/usr/bin/env ruby

# 引数ファイルの行数を取得
def file_lines(file)
  file.lines.count.to_s
end

# 引数ファイルの単語数を取得
def file_words(file)
  file.split(/\s+/).size.to_s
end

# 引数ファイルのバイトサイズを取得
def file_size(file)
  file.size.to_s
end

# 標準入力のファイル行数を取得
def input_lines(input)
  input.chomp.split("\n").count.to_s
end

# 標準入力の単語数を取得
def input_words(input)
  input.chomp.split(/\s+/).size.to_s
end

# 標準入力のバイトサイズを取得
def input_sizes(input)
  input.size.to_s
end

file_names = ARGV

if file_names.include?('-l')
  line_option = 'l'
  file_names.delete('-l')
end

# 標準入力の条件分岐
if file_names.empty? && line_option
  # lオプションがついた場合
  input = $stdin.read
  puts input_lines(input).rjust(8)
  # lオプションがつかない場合
elsif file_names.empty?
  input = $stdin.read
  puts "#{input_lines(input).rjust(8)}#{input_words(input).rjust(8)}#{input_sizes(input).rjust(8)}"
end

# ファイルが一つの場合の条件分岐
if file_names.count == 1 && line_option
  # lオプションがついた場合
  file = File.read(file_names[0])
  print file_lines(file).rjust(8)
  puts " #{file_names[0]}"
elsif file_names.count == 1
  # lオプションがつかない場合
  file = File.read(file_names[0])
  print "#{file_lines(file).rjust(8)}#{file_words(file).rjust(8)}#{file_size(file).rjust(8)}"
  puts " #{file_names[0]}"
end

# ファイルが複数の場合の条件分岐
if file_names.count > 1 && line_option
  # lオプションがついた場合
  lines_sum = 0
  file_names.each do |f|
    file = File.read(f)
    print file_lines(file).rjust(8)
    puts " #{f}"
    lines_sum += file_lines(file).to_i
  end
  puts "#{lines_sum.to_s.rjust(8)} total"
elsif file_names.count > 1
  # lオプションがつかない場合
  lines_sum = 0
  words_sum = 0
  sizes_sum = 0
  file_names.each do |f|
    file = File.read(f)
    print file_lines(file).rjust(8)
    print file_words(file).rjust(8)
    print file_size(file).rjust(8)
    puts " #{f}"
    lines_sum += file_lines(file).to_i
    words_sum += file_words(file).to_i
    sizes_sum += file_size(file).to_i
  end
  puts "#{lines_sum.to_s.rjust(8)}#{words_sum.to_s.rjust(8)}#{sizes_sum.to_s.rjust(8)} total"
end
