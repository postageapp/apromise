RSpec.describe APromise, type: :reactor do
  context 'will wait for the promise to be resolved' do
    it 'with a value' do
      promise = APromise.new
      result = nil
      resolved = false

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(result).to eq(nil)
      expect(promise).to be_waiting

      promise.resolve('test')

      expect(resolved).to be(true)
      expect(result).to eq('test')
      expect(task).to be_complete
    end

    it 'with a block' do
      promise = APromise.new
      result = nil
      resolved = false

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(result).to eq(nil)
      expect(promise).to be_waiting
      expect(promise).to_not be_resolved

      promise.resolve do
        'test'
      end

      expect(promise).to be_resolved
      expect(task).to be_complete

      expect(resolved).to be(true)
      expect(result).to eq('test')
    end

    it 'with a block that involves waiting' do
      promise = APromise.new

      expect(promise).to_not be_resolved

      condition = Async::Condition.new

      promise.resolve do
        condition.wait
      end

      expect(promise).to_not be_resolved

      condition.signal(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end

    it 'with a block that chains to another promise' do
      promise = APromise.new

      expect(promise).to_not be_resolved

      trigger = APromise.new

      promise.resolve do
        trigger
      end

      expect(promise).to_not be_resolved

      trigger.resolve(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end

    it 'with a block that implicitly waits on a condition' do
      promise = APromise.new

      expect(promise).to_not be_resolved

      trigger = Async::Condition.new

      promise.resolve do
        trigger
      end

      expect(promise).to_not be_resolved

      trigger.signal(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end

    it 'generating an exception' do
      promise = APromise.new
      result = nil
      resolved = false

      task = Async do
        begin
          promise.wait
        rescue Exception => e
          result = e
        ensure
          resolved = true
        end
      end

      expect(result).to eq(nil)
      expect(promise).to_not be_resolved
      expect(promise).to be_waiting

      promise.resolve do
        raise 'test'
      end

      expect(resolved).to be(true)
      expect(promise).to be_resolved
      expect(promise).to be_exception

      expect(result).to be_kind_of(RuntimeError)
      expect(result.to_s).to eq('test')
      expect(task).to be_complete
    end
  end

  context 'can be created using new' do
    it 'passing a value as an argument' do
      promise = APromise.new(:test)
      result = nil
      resolved = false

      expect(promise).to_not be_waiting
      expect(promise).to be_resolved

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(promise).to_not be_waiting
      expect(promise).to be_resolved
      expect(resolved).to be(true)
      expect(result).to eq(:test)
      expect(task).to be_complete
    end

    it 'passing a block argument' do
      promise = APromise.new do
        :test
      end

      expect(promise).to_not be_waiting
      expect(promise).to be_resolved

      result = nil
      resolved = false

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(promise).to_not be_waiting
      expect(resolved).to be(true)
      expect(result).to eq(:test)
      expect(task).to be_complete
    end

    it 'passing a block argument that generates an exception' do
      promise = APromise.new do
        raise 'test'
      end

      expect(promise).to_not be_waiting
      expect(promise).to be_resolved

      result = nil
      resolved = false

      task = Async do
        begin
          promise.wait
        rescue Exception => e
          result = e
        ensure
          resolved = true
        end
      end

      expect(promise).to_not be_waiting
      expect(resolved).to be(true)
      expect(result).to be_kind_of(RuntimeError)
      expect(result.to_s).to eq('test')
      expect(task).to be_complete
    end

    it 'passing a block argument that involves waiting' do
      condition = Async::Condition.new

      promise = APromise.new do
        condition.wait
      end

      expect(promise).to_not be_resolved

      condition.signal(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end

    it 'passing a block argument that chains to another promise' do
      trigger = APromise.new

      promise = APromise.new do
        trigger
      end

      expect(promise).to_not be_resolved

      trigger.resolve(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end

    it 'passing a block argument that implicitly waits on a condition' do
      trigger = Async::Condition.new

      promise = APromise.new do
        trigger
      end

      expect(promise).to_not be_resolved

      trigger.signal(:test)

      expect(promise).to be_resolved
      expect(promise.wait).to eq(:test)
    end
  end

  context 'can be defined' do
    it 'when previously resolved with a value' do
      promise = APromise.new
      result = nil
      resolved = false

      expect(result).to eq(nil)
      expect(promise).to_not be_waiting

      promise.resolve('test')

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(resolved).to be(true)
      expect(result).to eq('test')
      expect(task).to be_complete
    end

    it 'when previously resolved with a block' do
      promise = APromise.new
      result = nil
      resolved = false

      expect(result).to eq(nil)
      expect(promise).to_not be_waiting

      promise.resolve do
        'test'
      end

      task = Async do
        result = promise.wait
        resolved = true
      end

      expect(resolved).to be(true)
      expect(result).to eq('test')
      expect(task).to be_complete
    end


    it 'when previously generated an exception' do
      promise = APromise.new
      result = nil
      resolved = false

      expect(result).to eq(nil)
      expect(promise).to_not be_waiting

      promise.resolve do
        raise 'test'
      end

      task = Async do
        begin
          promise.wait
        rescue Exception => e
          result = e
        ensure
          resolved = true
        end
      end

      expect(resolved).to be(true)
      expect(result).to be_kind_of(RuntimeError)
      expect(result.to_s).to eq('test')
      expect(task).to be_complete
    end
  end
end
