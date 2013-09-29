require './utils'

require 'benchmark'
#$stdout.puts "Took: " + Benchmark.realtime {
#  @known_primes = Utils.get_primes(2, 99)
#  $stdout.puts "Number of primes: #{@known_primes.count}"
#  #$stdout.puts "Primes: #{@known_primes.inspect}"
#}.to_s + "s"

puts "Took: " + Benchmark.realtime {
  @circular = Utils.get_circular_primes(2, 999)
}.to_s + "s"

$stdout.puts "Circular primes: #{@circular.sort}"
$stdout.puts "Number of circular primes: #{@circular.count}"
