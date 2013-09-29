require './utils'

describe Utils do
  describe ".is_prime" do
    it "should return whether a number is prime or not" do
      primos = [2,3,5,7,11,13,17,19,23,29,31]
      not_primos = [4,6,8,9,10,12,14,15,16,18,21,22]

      primos.each { |n| Utils.is_prime(n).should == true }
      not_primos.each { |n| Utils.is_prime(n).should == false }
    end

    it "should return whether a number is prime or not, given a fixed list of divisors" do
      Utils.is_prime(2, []).should == true
      Utils.is_prime(3, [2]).should == true
      Utils.is_prime(4, [2]).should == false
      
      Utils.is_prime(13, [2,3,5,7,11]).should == true
      Utils.is_prime(18, [2,3,5,7,11,13,17]).should == false
    end
  end

  describe ".rotations" do
    it "should return every possible rotation of the number as an array" do
      Utils.rotations(123).should == [231, 312, 123]
      Utils.rotations(11).should == [11]
    end

    it "should not trim leading zeros" do
      Utils.rotations(3001).should == [1300, 3001]
    end
  end

  describe ".contains_all" do
    it "should return whether if every number in B exists in A" do
      Utils.contains_all([2,3,4,5], [2,5]).should == true
      Utils.contains_all([2,5], [2,3,4,5]).should == false
      Utils.contains_all([5], [2,3,4]).should == false
      Utils.contains_all([11, 13], [11, 11]).should == true
      Utils.contains_all([11, 13], [11]).should == true
    end
  end
  
  describe ".get_primes" do
    it "should return all primes between A and B" do
      Utils.get_primes(2, 20).should == [2,3,5,7,11,13,17,19]
      Utils.get_primes(20, 40).should == [23,29,31,37]
    end
  end

  describe ".get_circular_primes" do
    it "should return all circular primes between A and B, given a fixed list of prime numbers" do
      Utils.get_circular_primes(2, 99, [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]).should == [2,3,5,7,11,13,17,31,37,71,73,79,97]
    end
  end
end
