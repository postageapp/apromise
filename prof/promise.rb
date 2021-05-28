require 'bundler'

Bundler.require(:default)

require 'benchmark'

require_relative '../lib/apromise'

count  = 1_000_000

StackProf.run(
  mode: :cpu,
  raw: true,
  out: File.expand_path('../tmp/promise.dump', __dir__)
) do
  Async do |task|
    count.times do
      APromise.new do
        :example
      end
    end
  end
end
