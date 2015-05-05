def debug(data)
  data = [data] unless data.is_a?(Array)

  puts "\n\n"
  puts '#' * 200
  data.each do |item|
    p item
    puts '#' * 200
  end
  puts "\n\n"
end
