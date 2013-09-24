class RedisBase
  attr_accessor :id
  include Redis::Objects
  
  def initialize
    @id = Redis::Counter.new(self.class.to_s).increment
  end
end
