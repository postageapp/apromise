require 'async/condition'
require 'async/notification'

class APromise < Async::Condition
  # == Constants ============================================================
  
  VERSION = File.readlines(File.expand_path('../VERSION', __dir__)).first.chomp.freeze
  NOT_SPECIFIED = Object.new

  # == Extensions ===========================================================
  
  # == Properties ===========================================================
  
  # == Class Methods ========================================================
  
    def self.version
      VERSION
    end
  
  # == Instance Methods =====================================================

  def initialize(value: NOT_SPECIFIED)
    if (block_given?)
      begin
        @value = yield
      rescue Exception => e
        @value = e
      end
    elsif (value === NOT_SPECIFIED)
      # Do nothing
    else
      @value = value
    end

    super()
  end

  def waiting?
    @waiting.any?
  end

  def resolved?
    defined?(@value)
  end
  
  def resolve(value: nil, task: nil)
    @value = value

    if (block_given?)
      begin
        @value = yield
      rescue Exception => e
        @value = e
      end
    end

    reactor = (task ||= Async::Task.current).reactor

    reactor << Async::Notification::Signal.new(@waiting, @value)
    reactor.yield

    @waiting = [ ]

    nil
  end

  def wait
    if (defined?(@value))
      case (@value)
      when Exception
        raise @value
      else
        return @value
      end
    end

    super
  end
end
