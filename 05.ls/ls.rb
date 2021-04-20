#!/usr/bin/env ruby
require 'etc'

# 受け取った引数を一つ一つに分割して配列にいれる
option = if !ARGV[0].nil?
           ARGV[0].chars
         else
           []
         end

# aオプションを指定した場合の配列
all_items = Dir.children('.').sort.unshift('.', '..')
if option.include?('a')
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
items.reverse! if option.include?('r')

if option.include?('l')
  all_items = Dir.children('.').sort.unshift('.', '..')
  if option.include?('a')
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

  items.reverse! if option.include?('r')

  items.size.times do |t|
    file = {}

    # 全てのファイルタイプを取得
    case File.ftype(items[t])
    when 'directory'
      file_type = 'd'
    when 'file'
      file_type = '-'
    end

    # 全てのファイルのパーミッションを取得
    mode = File.stat(items[t]).mode.to_s(8)
    mode = mode[-3, 3].chars.map do |m|
      m.to_i.to_s(2)
    end
    permission = mode.map do |mo|
      permission_pattern = {'111' => 'rwx', '110' => 'rw-', '101' => 'r-x', '100' => 'r--', '011' => '-wx', '010' => '-w-', '001' => '--x', '000' => '---' }
      permission_pattern[mo]
    end
    file['file_type&permission'] = permission.join('').insert(0, file_type)

    # 全てのファイルのハードリンクの数を取得
    file_hard_link = File.stat(items[t]).nlink.to_s.insert(0, ' ' * (hard_link_length - File.stat(items[t]).nlink.to_s.length))
    file['hard_link'] = file_hard_link

    # 全てのファイルのオーナー名を取得
    file_owner_name = Etc.getpwuid(File.stat(items[t]).uid).name.insert(0, ' ' * (owner_name_length - Etc.getpwuid(File.stat(items[t]).uid).name.length))
    file['owner_name'] = file_owner_name

    # 全てのファイルのグループ名を取得
    file_group_name = Etc.getgrgid(File.stat(items[t]).gid).name.insert(0, ' ' * (group_name_length - Etc.getgrgid(File.stat(items[t]).gid).name.length))
    file['group_name'] = file_group_name

    # 全てのファイルのバイトサイズを取得
    file_byte_size = File.stat(items[t]).size.to_s.insert(0, ' ' * (byte_size_length - File.stat(items[t]).size.to_s.length))
    file['byte_size'] = file_byte_size

    # 全てのファイルのタイムスタンプを取得
    times = File.stat(items[t]).mtime.to_s.scan(/(-[01]\d-[01]\d) ([01]\d|2[0-3])(:[0-5]\d)/).flatten
    file['time_stamp'] = times.join(' ').tr('-', ' ').gsub(/^ 0/, ' ').gsub(/ :/, ':')

    # 全てのファイルのファイル名を取得
    file['file_name'] = items[t]

    puts file.values.join(' ')
  end
else
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

end
