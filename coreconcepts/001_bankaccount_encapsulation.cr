# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:
# Encapsulation is a class that hides it intrnal data and only lets you touch
# it through safe methods. lets imagine a piggy bank with a locked lid. Users can
# put money in and take money out ONLY through a slot. Users can put money in and take
# money out ONLY through that slot.
# A bankaccount encapsualtes its balance. external code cannot set @balance directly,
# it must go through deposit/withdraw functions which enforces business rules
#
#

class BankAccount
  # we create private instance variable using @ convention in crystal
  # @balance is a private instance variable
  @balance : Float64

  def initialize(@balance : Float64 =0.0)
    raise ArgumentError.new("Initial balance cannot be negative") if @balance < 0
  end

  # we create read-only accessor: users can see balance but cannot assign to it.
  # using getter
  getter balance

  #Deposit function is the only approach to add money
  def deposit(amount : Float64) : Float64
    raise ArgumentError.new("Deposit must be positive") unless amount>0
    @balance += amount
    @balance
  end

  #withdraw enforces the invariant that balance never goes negative
  def withdraw (amount : Float64) : Float64
    raise ArgumentError.new("Withdrawal must be positive") unless amount > 0
    raise "Insufficient funds" if amount > balance
    @balance -= amount
    @balance
  end

  # A safe display method (no mutating logic leaks out)
  # # this is the to string method
  def to_s(io : IO) : Nil
    io << "BankAccount(balance=#{@balance.round(2)})"
  end

end

#Execution
#----------------------------------------------------------
account = BankAccount.new(100.0)
puts account
account.deposit(50.0)
puts account
account.withdraw(30.0)
puts account
begin
  account.withdraw(10_000.0)
rescue ex
  puts "Rejected: #{ex.message}"
end

# =============================================================================
# EXERCISE 1
#   Add a `transfer_to(other : BankAccount, amount)` method that atomically
#   withdraws from self and deposits to other. If the withdraw fails, the
#   other account must be untouched.
#
# SOLUTION 1:
#   def transfer_to(other : BankAccount, amount : Float64) : Nil
#     withdraw(amount)          # raises first, so no partial state
#     other.deposit(amount)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Expose a read-only `history` of operations without letting callers
#   mutate the array. Return a copy.
#
# SOLUTION 2:
#   Add @history = [] of String in initialize, push on each op, and:
#     def history : Array(String)
#       @history.dup
#     end
#   (Returning a dup prevents external mutation of the internal array.)
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a `frozen` flag: once frozen, no deposits or withdrawals are allowed.
#
# SOLUTION 3:
#   @frozen : Bool = false
#   def freeze!; @frozen = true; end
#   In deposit/withdraw: raise "Account frozen" if @frozen
# =============================================================================
