class Gossip
	def initialize(origin, destination, news)
		@origin = origin
		@destination = destination
		@news = news
		@destination_news = news.collect(&:duplicate)
		#puts "A: #{@news.collect {|news| news.known_by.object_id}}"
		#puts "B: #{@destination_news.collect {|news| news.known_by.object_id}}"
	end

	def exchange
		@news.each do |news|
			#puts " #{@origin.id} is exchanging #{news.id} with #{@destination.id}"
			news.sent(@destination)
		end
		@destination_news.each do |news|
			news.add_to_known_by_list(@origin)
			@destination.acquire_knowledge(news)
			#puts " exchanged. Known by: #{news.known_by}"
		end
	end
end
