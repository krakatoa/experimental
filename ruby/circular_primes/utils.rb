module Utils
  class << self
    def is_prime(n, divisors=(2..n-1))
      if (n > 2)
        divisors.each do |d|
          return false if (n % d == 0)
        end
        return true
      else
        return true
      end
    end

    def rotations(n)
      rotations = []
      n = n.to_s

      n.length.times do
        n = n[1..-1] + n[0]
        rotations.push(n.to_i) if n[0] != "0"
      end
      rotations.uniq
    end

    def contains_all(a, b)
      b.each {|n| return false if not a.include?(n)}; return true
    end

    def get_primes(a, b)
      divisors = []
      divisors = (2..a).to_a if a > 2
      (a..b).inject([]) do |primes, n|
        primes.push(n) if Utils.is_prime(n, divisors + primes)
        primes
      end
    end

    def get_circular_primes(a, b, primes=nil)
      primes = primes ? primes.dup : get_primes(a, b)
      circular = []

      while primes.length > 0
        n = primes[0]
        r = Utils.rotations(n)

        if Utils.contains_all(primes, r)
          circular.concat(r)
          r.each do |to_rem|
            primes.delete(to_rem)
          end
        end
        primes.delete(n)
      end
      circular.sort
    end

  end
end
