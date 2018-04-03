require 'yaml/store'

class IdeaStore
  def self.all
    [].tap do |ideas|
      raw_ideas.each_with_index do |data, i|
        ideas << Idea.new(data.merge("id" => i))
      end
    end
  end

  def self.create(data)
    database.transaction do
      database['ideas'] << data
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge("id" => id))
  end

  def self.update(id, data)
    database.transaction do
      database['ideas'][id] = data
    end
  end

  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end
  
  private

  def self.database
    return @database if @database

    @database = YAML::Store.new("db/ideabox")
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.raw_ideas
    database.transaction { |db| db['ideas'] || [] }
  end 

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end
end
