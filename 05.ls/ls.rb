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
  except_dot_items = all_items.map { |item| item if /^[^.]+/.match?(item) }
  items = except_dot_items.compact
end

# rオプションを使用した場合に配列を逆順に
items.reverse! if option.include?('r')

if option.include?('l')
  all_items = Dir.children('.').sort.unshift('.', '..')
  if option.include?('a')
    items = all_items
  # aオプションを使用しなかった場合の配列
  else
    except_dot_items = all_items.map { |item| item if /^[^.]+/.match?(item) }
    items = except_dot_items.compact
  end

  file_blocks = items.map { |item| File.stat(item).blocks }

  puts "total #{file_blocks.sum}"

  # ハードリンクの長さを測定
  hard_links = items.map { |item| File.stat(item).nlink.to_s }
  hard_link_length = hard_links.max_by(&:length).length

  # オーナーネームの長さを測定
  owner_names = items.map { |item| Etc.getpwuid(File.stat(item).uid).name }
  owner_name_length = owner_names.max_by(&:length).length

  # group_nameの長さを取得
  group_names = items.map { |item| Etc.getgrgid(File.stat(item).gid).name }
  group_name_length = group_names.max_by(&:length).length

  # byte_sizeの長さを取得
  byte_sizes = items.map { |item| File.stat(item).size.to_s }
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
  arranged_items << nil while (arranged_items.size % 3) != 0
  # case items.size % 3
  # when 1
  #   2.times do
  #     arranged_items << nil
  #   end
  # when 2
  #   arranged_items << nil
  # end

  # 一応並べられた
  results.each do |row|
    puts row.join('  ')
  end

end
