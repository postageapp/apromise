require 'benchmark'
require 'async'

class Example
  def wait
    # ... Nothing in particular
  end
end

Async do |task|
  Benchmark.benchmark do |bm|
    count = 1_000_000

    bm.report(:obj_method) do
      count.times do
        Example.new.wait
      end
    end

    bm.report(:async_task) do
      count.times do
        task.async do
          :test
        end
      end
    end
  end
end
