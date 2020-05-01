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

      promise.resolve(value: 'test')

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

      expect(resolved).to be(true)
      expect(result).to eq('test')
      expect(task).to be_complete
      expect(promise).to be_resolved
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
      expect(result).to be_kind_of(RuntimeError)
      expect(result.to_s).to eq('test')
      expect(task).to be_complete
    end
  end

  context 'can be created with an existing value' do
    it 'passed as value argument' do
      promise = APromise.new(value: :test)
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

    it 'passed as block argument' do
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

    it 'passed as block argument that generates an exception' do
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
  end

  context 'will return the value produced' do
    it 'when previously resolved with a value' do
      promise = APromise.new
      result = nil
      resolved = false

      expect(result).to eq(nil)
      expect(promise).to_not be_waiting

      promise.resolve(value: 'test')

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
