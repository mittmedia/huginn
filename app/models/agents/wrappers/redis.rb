require 'digest/md5'
require 'redis'

module Agents::WRAPPERS::REDIS

  def self.redis
    # @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
    @redis = Redis.new(:host => "127.0.0.1", :port => 6379, :db => 15)
  end

  def self.digest(key, data)
    red = redis
    digest = Digest::MD5.hexdigest(data.to_s).to_s
    return false if digest == red.get(key)
    red.set(key, digest)
    return true
  end
end