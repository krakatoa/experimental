class News
	MAX_TRIES = 4
	# DECAY_TYPE = :always
	DECAY_TYPE = :on_sent
	
	attr_reader :id, :known_by, :sent_to, :tries
	
	def initialize(id, tries=0, known_by=[], sent_to=[])
		@id = id
		@tries = tries
		@known_by = known_by
		@sent_to = sent_to
	end

	def sent(destination)
		@sent_to << destination.id
    decay if News::DECAY_TYPE == :on_sent
	end

  def decay
    @tries += 1
  end
	
	def add_to_known_by_list(node)
		@known_by << node.id
	end

	def add_nodes_to_known_by_list(node_ids)
		@known_by += node_ids
		@known_by = @known_by.uniq
	end

	def duplicate
		News.new(@id, @tries, @known_by.dup, @sent_to.dup)
	end

  def self.number_of_rounds
    rounds = 0
    sum = 0
    index = 1
    begin
      rounds += 1
      sum += index
      index = index * 2
    end while sum < Node.size
    rounds + 1
    # 1
  end

end
