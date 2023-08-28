#Require every jar from the maven directory
folder = '/usr/lib/perfsonar/logstash/java/maven/'
Dir["#{folder}/**/*.jar"].each { |jar| require jar }

#import classes we want to use
java_import 'com.github.benmanes.caffeine.cache.LoadingCache'
java_import 'java.time.Duration'

class RateCache
    #Instantiate cache
    @@RATE_CACHE_MAX_ENTRIES = ENV['RATE_CACHE_MAX_ENTRIES'] ? ENV['RATE_CACHE_MAX_ENTRIES'].to_i : 10000000
    @@RATE_CACHE_EXPIRES = ENV['RATE_CACHE_EXPIRES'] ? ENV['RATE_CACHE_EXPIRES'].to_i : 600
    @@cache = Java::ComGithubBenmanesCaffeineCache::Caffeine.newBuilder().maximumSize(@@RATE_CACHE_MAX_ENTRIES).expireAfterWrite(Duration.ofSeconds(@@RATE_CACHE_EXPIRES)).build()

    def self.get(k)
        return @@cache.getIfPresent(k)
    end

    def self.put(k, v)
        @@cache.put(k, v)
    end

    def self.delete(k)
        @@cache.invalidate(k)
    end

    def self.stats()
        return @@cache.stats()
    end

    def self.size()
        return @@cache.estimatedSize()
    end

end