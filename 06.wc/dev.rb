file = File.open('README.md').read
# p file.bytes                                            # バイト列変換
#     .map { |i| i.to_s(16) }                           # 16進数変換
#     .map { |h| h.gsub(/85|a0|20|(0[9a-d])/, ' ') }  # 半角空白へ置換
#     .join                                             # 結合
#     .split(' ')                                       # 分割
#     .size                                             # カウント

p file.bytes.map { |i| i.to_s(16) }.map { |h| h.gsub(/85|a0|20|(0[9a-d])/, ' ') }.join.split(' ').size
