#!/usr/bin/env ruby

require_relative 'jump_consistent_hash'
require 'securerandom'

KEYS = 10000

start_key = (ARGV[0] || SecureRandom.random_number(1 << 60)).to_i
puts "start_key #{start_key}"
stop_key = start_key + KEYS - 1

keys = (start_key..stop_key).to_a
assigns = Array.new(KEYS, 0)

dev_ratio_max = 0
move_ratio_max = 0

(2..100).each do |buckets|
  bucket_counts = Array.new(buckets, 0)
  jch = JumpConsistentHash.new(buckets)
  moved = 0
  keys.each_with_index do |key, i|
    bucket = jch.bucket(key)
    bucket_counts[bucket] += 1
    if bucket != assigns[i]
      unless bucket == buckets - 1
        fail "Shuffle move (#{assigns[i]} -> #{bucket}):  #{buckets} #{key}"
      end
      assigns[i] = bucket
      moved += 1
    end
  end
  avg = KEYS.to_f / buckets
  p = 1.0 / buckets
  binomial_stdev = Math.sqrt(KEYS * p * (1.0 - p))
  dev_ratio = (bucket_counts.max - bucket_counts.min) / binomial_stdev
  if dev_ratio > dev_ratio_max
    dev_ratio_max = dev_ratio
    puts "#{buckets} #{avg} #{bucket_counts.min}-#{bucket_counts.max} #{dev_ratio}"
    if dev_ratio > 7.0
      fail "Excessive deviation #{dev_ratio}"
    end
  end
end
