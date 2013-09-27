class Node
	@@nodes = []
	@@number_of_rounds = 0

	attr_reader :id

	def initialize(id=nil)
		@id = id || @@nodes.last.id + 1 rescue 0
		@@nodes << self
		@news_manager = NewsManager.new
	end

	def news
		@news_manager.news
	end

	def news_state
		"Node(#{@id}) #{@news_manager.news_state}"
	end

	def news_for(destination)
		@news_manager.news_for(destination)
	end

	def acquire_knowledge(news)
		@news_manager.acquire(news)
	end
	
	def random_destination
		nodes = (@@nodes - [self])
		nodes[rand(nodes.size)]
	end

  def self.size
    @@nodes.size
  end

	def self.knowledge(news_number)
		puts "Round number #{@@number_of_rounds} (each news@#{News.number_of_rounds})"
		#@@nodes.each do |node|
		#	puts "Node #{node.id}: #{node.news.collect(&:id).join(', ')}"
		#end
		current_news = @@nodes.inject(0){|b, v| b + v.news.size }
    total_messages = news_number * @@nodes.size
    stale_messages = @@nodes.inject(0) {|b, v| b + v.news.select{|n| n.tries >= News.number_of_rounds}.size}
    puts "#{(100.to_f * current_news) / total_messages}% (#{current_news} out of #{total_messages}. #{stale_messages} are obsolte) ===="
	end

	def self.news_state
		@@nodes.each do |node|
			puts node.news_state
		end
	end

	def self.gossip(news_number)
		gossips = @@nodes.collect do |node|
			destination = node.random_destination
			Gossip.new(node, destination, node.news_for(destination))
		end

		@@number_of_rounds += 1

		gossips.each do |gossip|
			gossip.exchange
		end

		Node.knowledge(news_number)
		Node.news_state
	end
end
