require 'md5'

module Agents::WRAPPERS::REDIS
  def redis
    @redis ||= Redis.connect(url: ENV.fetch('REDIS_URL'))
  end

  def self.digest(key, data)
    digest = Digest::MD5.hexdigest(data).to_s
    return false if digest == redis.get(key)
    redis.set(key, digest)
  end
end