ENV['RAILS_ENV'] = 'production'
require 'benchmark/ips'

require File.expand_path("../../config/environment", __FILE__)

Benchmark.ips do |b|
  b.report do |times|
    i = -1
    I18n.t('posts') while (i+=1) < times
  end
end
