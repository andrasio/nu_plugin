los_tres_caballeros = %i[robalino turner katz josh]
words = ['le gusta', 'C', 'likes', 'Ok']

[].tap do |rustaceans|
  los_tres_caballeros.shuffle.each do |caballero|
    word = words[rand(words.count)]
    rustaceans << "#{caballero} #{word}(arepa)"
  end
end
