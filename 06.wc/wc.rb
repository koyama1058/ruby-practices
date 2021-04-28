argument = ARGV

if argument.include?('-l')
  option = 'l'
  argument.delete('-l')
end

files_info = []
word_width = 8

# 選択したファイルを本来は配列に入れてループ処理させる
argument.size.times do |t|
  select_item = argument[t]

  file = File.read(select_item)

  file_info = { 'file_lines' => nil, 'file_words' => nil, 'file_size' => nil, 'file_name' => nil }

  # 行数を取得
  file_info['file_lines'] = file.lines.count.to_s.insert(0, ' ' * (word_width - file.lines.count.to_s.length))

  # 単語数を取得
  file_info['file_words'] = file.split(/\s+/).size.to_s.insert(0, ' ' * (word_width - file.split(/\s+/).size.to_s.length))

  # バイト数を取得
  file_info['file_size'] =  File.stat(select_item).size.to_s.insert(0, ' ' * (word_width - File.stat(select_item).size.to_s.length))

  # ファイル名を取得
  file_info['file_name'] = select_item

  if option
    print "#{file_info['file_lines']} "
    puts file_info['file_name']
  else
    puts file_info.values.join(' ')
  end
  files_info << file_info
end

if argument.length >= 2
  files_lines = []
  files_words = []
  files_size = []

  files_info.each do |t|
    files_lines << t['file_lines'].to_i
    files_words << t['file_words'].to_i
    files_size << t['file_size'].to_i
  end
  total_file_info = { 'file_lines' => nil, 'file_words' => nil, 'file_size' => nil, 'file_name' => nil }

  total_file_info['file_lines'] = files_lines.sum.to_s.insert(0, ' ' * (word_width - files_lines.sum.to_s.length))
  total_file_info['file_words'] = files_words.sum.to_s.insert(0, ' ' * (word_width - files_words.sum.to_s.length))
  total_file_info['file_size'] = files_size.sum.to_s.insert(0, ' ' * (word_width - files_size.sum.to_s.length))
  total_file_info['file_name'] = 'total'
  if option
    print "#{total_file_info['file_lines']} "
    puts 'total'
  else
    puts total_file_info.values.join(' ')
  end

end
