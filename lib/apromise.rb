require 'async'
require 'async/condition'
require 'async/notification'
require 'async/task'

class APromise < Async::Condition
  # == Constants ============================================================

  VERSION = File.readlines(File.expand_path('../VERSION', __dir__)).first.chomp.freeze
  NOT_SPECIFIED = Object.new.freeze

  # == Exceptions ===========================================================

  Error = Class.new(StandardError)
  AlreadyResolved = Class.new(Error)

  # == Extensions ===========================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  # Returns the version of APromise
  def self.version
    VERSION
  end

  # Creates a pre-resolved promise using either the supplied block, or if no
  # block is provided, the value which defaults to nil.
  def self.resolve(value = nil, &block)
    new(value, &block)
  end

  # == Instance Methods =====================================================

  # Creates a new promise with an option pre-defined result value, or a block
  # to resolve into a value. Can also be initialized in an undefined state
  # for later resolution using resolve
  def initialize(value = NOT_SPECIFIED, &block)
    @task = Async::Task.current

    if (block_given?)
      super()

      execute!(&block)
    elsif (value === NOT_SPECIFIED)
      # Do nothing, and do not assign @value which indicates "resolved"
      super()
    else
      # As there's no waiting here, super() can be skipped for efficiency
      @value = value
    end
  end

  # Indicates if any operations are waiting on the resolution of this
  # promise.
  def waiting?
    @waiting&.any? or false
  end

  # Returns true if resolved, false otherwise
  def resolved?
    !!defined?(@exception) or !!defined?(@value)
  end

  # Returns true if an exception was generated, false otherwise
  def exception?
    !!defined?(@exception)
  end

  # Reassigns which task this promise should be considered attached to
  def for_task(task)
    @task = task

    self
  end

  # Resolves the promise with the supplied block, or if no block is given,
  # the value, defaulting to nil. If the promise has already been resolved
  # will raise APromise::AlreadyResolved
  def resolve(value = nil, &block)
    if (resolved?)
      raise AlreadyResolved, "Promise was previously resolved"
    end

    reactor = @task.reactor

    if (block_given?)
      execute!(&block)
    else
      @value = value

      signal!(@value)
    end

    self
  end

  def error(exception)
    if (resolved?)
      raise AlreadyResolved, "Promise was previously resolved"
    end

    @exception = exception

    signal!(@exception)

    self
  end

  def wait
    if (defined?(@exception))
      raise @exception
    end

    if (defined?(@value))
      return @value
    end

    super
  end

protected
  def signal!(result)
    @waiting.each do |fiber|
      fiber.resume(result) if (fiber.alive?)
    end

    @waiting = [ ]

    result
  end

  def settle(value)
    loop do
      case (value)
      when APromise, Async::Task, Async::Condition
        value = value.wait
      else
        break value
      end
    end
  end

  def execute!(&block)
    @task.async do |task|
      @value = settle(yield(task))

      signal!(@value)
    rescue Async::Stop
      # Something interrupted this operation, so just stop.
    rescue Object => e
      @exception = e

      signal!(@exception)
    end
  end
end
