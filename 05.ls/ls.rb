#!/usr/bin/env ruby
require 'etc'

PERMISSION_PATTERN = { '111' => 'rwx', '110' => 'rw-', '101' => 'r-x', '100' => 'r--', '011' => '-wx', '010' => '-w-', '001' => '--x', '000' => '---' }.freeze

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
  hard_links = items.map { |item| File.stat(item).nlink.to_s }
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

    permissions = mode.map { |mo| PERMISSION_PATTERN[mo] }
    file['file_type&permission'] = file_type + permissions.join('')

    # 全てのファイルのハードリンクの数を取得
    file['hard_link'] = File.stat(items[t]).nlink.to_s.rjust(hard_link_length)

    # 全てのファイルのオーナー名を取得
    file['owner_name'] = Etc.getpwuid(File.stat(items[t]).uid).name.rjust(owner_name_length)

    # 全てのファイルのグループ名を取得
    file['group_name'] = Etc.getgrgid(File.stat(items[t]).gid).name.rjust(group_name_length)

    # 全てのファイルのバイトサイズを取得
    file['byte_size'] = File.stat(items[t]).size.to_s.rjust(byte_size_length)

    # 全てのファイルのタイムスタンプを取得
    time = File.stat(items[t]).mtime
    file['time_stamp'] = " #{time.month} #{time.day} #{format('%02d', time.hour)}:#{format('%02d', time.min)}"

    # 全てのファイルのファイル名を取得
    file['file_name'] = items[t]

    puts file.values.join(' ')
  end
else
  # ファイルで一番長いものの文字数を取得
  max_words = items.map(&:length).max.to_i
  arranged_items = items.map { |item| item.ljust(max_words) }
  # 縦横を入れ替えるためにnilを追加
  case items.size % 3
  when 1
    arranged_items << nil
    arranged_items << nil
  when 2
    arranged_items << nil
  end
  # p arranged_items
  allow_size = arranged_items.size / 3

  # 縦横を入れ替える
  results = arranged_items.each_slice(allow_size).to_a.transpose

  # 一応並べられた
  results.each do |row|
    puts row.join('  ')
  end

end
