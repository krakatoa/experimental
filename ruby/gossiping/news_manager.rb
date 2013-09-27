class NewsManager
	attr_reader :news

	def initialize
		@news = []
	end

	def acquire(news)
		# make usage of versions
		#news.each do |item_news|
			if not @news.collect(&:id).include?(news.id)
				@news << news
			else
				@news.select{|n| n.id == news.id}[0].add_nodes_to_known_by_list(news.known_by)
			end
		#end
	end

	def news_for(destination)
    available = @news.select { |max| max.tries < News.number_of_rounds } # number of rounds should be variable according actual number ?

    if News::DECAY_TYPE == :always
      available.each do |news|
        news.decay
      end
    end

		available.select { |news|
			!news.known_by.include?(destination.id) and !news.sent_to.include?(destination.id)
		}
	end

	def news_state
		@news.collect {|news| "#{news.id}(#{news.tries})"}.join(" ")
		#@news.select {|news| news.tries < News.number_of_rounds}.collect {|news| "#{news.id}(#{news.tries})"}.join(" ")
	end
end
