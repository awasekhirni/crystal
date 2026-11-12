# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:Open/Closed Principle classes should be OPEN for extension
# but CLOSED for modificaiton. Add new discounts without editing existing ones.
# A shop's discount rules shouldnt require cutting the register open everytime
# marketing invents a new sale
#

# the case of bad implementation of OCP
# adding "black friday discounts" would mean editigint his method
# a modification not extension

def discount(type : Symbol, amount : Float64)
  case type
    when :none then 0.0
    when :percent then amount * 0.10
    when :flat  then 5.0
  end
end



# correct implementation of OCP compliant
# # each discount is a self-continaed object; the register never changes
module Discount
  abstract def apply(amount : Float64) : Float64
end

class NoDiscount
  include Discount
  def apply(amount : Float64) : Float64; amount; end
end


class PercentDiscount
  include Discount
  def initialize(@pct : Float64); end
  def apply(amount : Float64) : Float64
    amount * (1.0 -@pct)
  end
end

class FlatDiscount
  include Discount
  def initialize(@off : Float64); end
  def apply(amount : Float64) : Float64
    Math.max(0.0, amount - @off)
  end
end

class Register
  def initialize(@discount : Discount = NoDiscount.new); end
  def total(amount : Float64) : Float64; @discount.apply(amount); end
end


#--- execution
puts Register.new(PercentDiscount.new(0.10)).total(100.0)  # 90.0
puts Register.new(FlatDiscount.new(15.0)).total(100.0)     # 85.0
puts Register.new.total(100.0)                              # 100.0

# =============================================================================
# EXERCISE 1
#   Add a BlackFridayDiscount (50% off) WITHOUT modifying any existing class.
# SOLUTION 1:
#   class BlackFridayDiscount
#     include Discount
#     def apply(amount : Float64) : Float64; amount * 0.5; end
#   end
#   puts Register.new(BlackFridayDiscount.new).total(100.0)  # 50.0
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Combine two discounts via a CompositeDiscount.
# SOLUTION 2:
#   class CompositeDiscount
#     include Discount
#     def initialize(@first : Discount, @second : Discount); end
#     def apply(amount : Float64) : Float64
#       @second.apply(@first.apply(amount))
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a "buy two, get 10% off" that needs quantity — extend the contract
#   with a new interface rather than editing Discount.
# SOLUTION 3:
#   module QuantityDiscount
#     abstract def apply_qty(amount : Float64, qty : Int32) : Float64
#   end
#   Register gets a new overload `total(amount, qty)` that dispatches only
#   to QuantityDiscount-capable objects. Existing code stays untouched.
# =============================================================================
#
#
