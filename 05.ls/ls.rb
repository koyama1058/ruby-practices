require 'pry'
require 'etc'

# 受け取った引数を一つ一つに分割して配列にいれる
if ARGV[0] != nil
  option = ARGV[0].chars
else
  option = []
end

# aオプションを指定した場合の配列
all_items = Dir.children('.').sort.unshift('.', '..') 
if option.include?("a")
  items = all_items
# aオプションを使用しなかった場合の配列
else  
  except_dot_items = []
  all_items.each do |item|
    except_dot_items << item if /^[^.]+/.match?(item)
  end
  items = except_dot_items
end

# rオプションを使用した場合に配列を逆順に
items.reverse! if option.include?("r")

unless option.include?("l")
  # ファイルで一番長いものの文字数を取得
  max_words = items.max_by(&:length).length
  items.map do |item|
    item.concat(' ' * (max_words - item.length))
  end
  # 縦横を入れ替えるためにnilを追加
  allow_size = items.size / 3 + 1
  add_nil = allow_size * 3 - items.size
  add_nil.times do
    items << nil
  end
  # 縦横を入れ替える
  results = items.each_slice(allow_size).to_a.transpose

  # 一応並べられた
  results.each do |row|
    puts row.join('  ')
  end

else
  all_items = Dir.children('.').sort.unshift('.', '..') 
  if option.include?("a")
    items = all_items
  # aオプションを使用しなかった場合の配列
  else  
    except_dot_items = []
    all_items.each do |item|
      except_dot_items << item if /^[^.]+/.match?(item)
    end
    items = except_dot_items
  end

  file_blocks = []
  items.each do |item|
    file_blocks << File.stat(item).blocks
  end
  puts "total #{file_blocks.sum}"

  # ハードリンクの長さを測定
  hard_links = []
  items.each do |item|
    hard_links << File.stat(item).nlink.to_s
  end
  hard_link_length = hard_links.max_by(&:length).length

  # オーナーネームの長さを測定
  owner_names = []
  items.each do |item|
    owner_names << Etc.getpwuid(File.stat(item).uid).name
  end
  owner_name_length = owner_names.max_by(&:length).length

  # group_nameの長さを取得
  group_names = []
  items.each do |item|
    group_names << Etc.getgrgid(File.stat(item).gid).name
  end
  group_name_length = group_names.max_by(&:length).length

  # byte_sizeの長さを取得
  byte_sizes = []
  items.each do |item|
    byte_sizes << File.stat(item).size.to_s
  end
  byte_size_length = byte_sizes.max_by(&:length).length

  items.size.times do |t|
    file = { 'file_type&permission' => nil, 'hard_link' => nil, 'owner_name' => nil, 'group_name' => nil, 'byte_size' => nil, 'time_stamp' => nil,
            'file_name' => nil }

    # 全てのファイルタイプを取得
    if File.ftype(items[t]) == 'directory'
      file_type = 'd'
    elsif File.ftype(items[t]) == 'file'
      file_type = '-'
    end

    # 全てのファイルのパーミッションを取得
    mode = '0%o' % File.stat(items[t]).mode
    mode = mode[-3, 3].chars.map do |m|
      m.to_i.to_s(2)
    end
    m = mode.map do |m|
      case m
      when '111'
        m = 'rwx'
      when '110'
        m = 'rw-'
      when '101'
        m = 'r-x'
      when '100'
        m = 'r--'
      when '011'
        m = '-wx'
      when '010'
        m = '-w-'
      when '001'
        m - '--x'
      when '000'
        m = '---'
      end
    end
    file['file_type&permission'] = m.join('').insert(0, file_type)

    # 全てのファイルのハードリンクの数を取得
    file_hard_link = File.stat(items[t]).nlink.to_s
    file_hard_link = file_hard_link.insert(0, ' ' * (hard_link_length - file_hard_link.length))
    file['hard_link'] = file_hard_link

    # 全てのファイルのオーナー名を取得
    file_owner_name = Etc.getpwuid(File.stat(items[t]).uid).name
    file_owner_name = file_owner_name.insert(0, ' ' * (owner_name_length - file_owner_name.length))
    file['owner_name'] = file_owner_name

    # 全てのファイルのグループ名を取得
    file_group_name = Etc.getgrgid(File.stat(items[t]).gid).name
    file_group_name = file_group_name.insert(0, ' ' * (group_name_length - file_group_name.length))
    file['group_name'] = file_group_name

    # 全てのファイルのバイトサイズを取得
    file_byte_size = File.stat(items[t]).size.to_s
    file_byte_size = file_byte_size.insert(0, ' ' * (byte_size_length - file_byte_size.length))
    file['byte_size'] = file_byte_size

    # 全てのファイルのタイムスタンプを取得
    times = File.stat(items[t]).mtime.to_s.scan(/(-[01]\d-[01]\d) ([01]\d|2[0-3])(:[0-5]\d)/).flatten
    file['time_stamp'] = times.join(' ').tr('-', ' ').gsub(/^ 0/, ' ').gsub(/ :/, ':')

    # 全てのファイルのファイル名を取得
    file['file_name'] = items[t]

    puts file.values.join(' ')
  end
end