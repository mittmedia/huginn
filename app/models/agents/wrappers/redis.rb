require 'digest/md5'
require 'redis'

module Agents::WRAPPERS::REDIS
  def self.redis
    @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
    # @redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 15)
  end

  def self.digest(key, data)
    red = redis
    # red.flushall
    digest = Digest::MD5.hexdigest(data.to_s).to_s
    # p "=========.#{digest} och #{red.get(key)}"
    if digest == red.get(key)
      # Rails.logger.info("Redis key: #{red.get(key)}, Key: #{key}")
      return false
    end
    # Rails.logger.info("Digest: #{digest}, Key:#{key}")
    red.set(key, digest)
    # Rails.logger.info("Ny redis key: #{red.get(key)}")
    return true
  end
end