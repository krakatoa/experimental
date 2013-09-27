require './news'
require './gossip'
require './news_manager'
require './node'

@news_number = 10# 100

@nodes = []
20.times { @nodes << Node.new } # 50

@id_news = 0
@news = []

def add_news
  @news_number.times { @news << News.new(@id_news += 1) }
  @news.each { |news| @nodes[rand(@nodes.size)].acquire_knowledge(news)}
end

puts "Nodes: 20"
puts "Enter 'news' to add #{@news_number} more messages randomly distributed across nodes"
puts "Press enter to simulate a new round of gossiping"

while true
  print "> "
	a = gets
  a = a.chomp
  if a == "news"
    add_news
    Node.knowledge(@id_news)
    Node.news_state
  else
	  Node.gossip(@id_news)
  end
  puts "\n(hit enter to spread the news, type 'news' and enter to add #{@news_number} more, or 'end' to quit)"
	break if a == "end"
end
