require 'eventmachine'
require 'evma_httpserver'
require 'em-http-request'
require 'English'
require 'json'

# :nodoc: namespace
module QueueSrv

class Matcher
  def initialize(nexus)
    @nexus = nexus
    @log = nexus.log
  end

  def find_matches
    @log.debug 'Attempting to find a matching'

    @nexus.matchable_users do |users|
      @log.debug "Found #{users.length} users ready to be matched"
      if users.length >= 2
        @log.debug "Matched two users"

        user1 = users[0]
        user2 = users[1]
        report_match user1, user2 do
          user1.found_match user2
          user2.found_match user1
        end
      end
    end
  end
  
  def report_match(user1, user2, &block)
    url = user1.match_url
    post_body = { mk1: user1.match_key, mk2: user2.match_key }
    request = EventMachine::HttpRequest.new(url).post(body: post_body)
    request.errback do
      @log.warn "Failed to report match to Web server"
    end
    request.callback do
      @log.debug "Match reported"
      block.call
    end
  end

  def run
    EventMachine::PeriodicTimer.new 1 do
      find_matches
    end
  end
end  # class QueueSrv::HttpServer

end  # namespace QueueSrv
