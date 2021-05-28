require 'benchmark'

require_relative '../lib/apromise'

Async do
  Benchmark.benchmark do |bm|
    count = 1_000_000

    bm.report(:with_value) do
      count.times do
        APromise.new(:test)
      end
    end

    bm.report(:with_block) do
      count.times do
        APromise.new do
          :test
        end
      end
    end
  end
end
