# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:
#   You're entering data into a database in a transaction. If a later step
#   fails, you roll back to the state before the transaction started. Memento
#   = snapshot for atomic rollback, at the object level.
#
# SETUP:
#   crystal run 080_memento_transaction.cr
# =============================================================================

# --- Memento (state) ------------------------------------------------------
class AccountSnapshot
  getter balance : Float64, name : String
  def initialize(@balance : Float64, @name : String); end
end

# --- Originator -----------------------------------------------------------
class BankAccount
  property balance : Float64, name : String
  def initialize(@balance : Float64, @name : String); end

  # Return the result of `snapshot`.
  def snapshot : AccountSnapshot; AccountSnapshot.new(@balance, @name.dup); end
  # Return the result of `restore`.
  def restore(m : AccountSnapshot) : Nil
    @balance = m.balance
    @name = m.name
  end

  # Return the result of `transfer_out`.
  def transfer_out(amount : Float64) : Nil
    raise "insufficient funds" if @balance < amount
    @balance -= amount
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "#{@name}: $#{@balance}"; end
end

# --- Transactional runner using memento --------------------------------
def transaction(account : BankAccount, &)
  before = account.snapshot
  begin
    yield
  rescue ex
    account.restore(before)
    puts "rolled back: #{ex.message}"
  end
end

# ---- Demonstration ----------------------------------------------------------
acct = BankAccount.new(1000.0, "Alice")
puts acct

# succeeds
transaction(acct) do
  acct.transfer_out(200.0)
  acct.name = "Alice (member)"
end
puts acct

# fails: balance unchanged
transaction(acct) do
  acct.transfer_out(50.0)
  acct.transfer_out(10_000.0)  # raises → rollback
end
puts acct

# =============================================================================
# EXERCISE 1
#   Add nested transactions (rollback to the innermost on inner failure).
# SOLUTION 1:
#   # Since transaction() snapshots before yield and restores on raise, wrap
#   # inner calls inside the outer yield. The inner rescue prevents outer from
#   # raising, so outer sees success. Snapshot stack emerges naturally.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Write an "undo" stack of AccountSnapshot for explicit user undo.
# SOLUTION 2:
#   @history = [] of AccountSnapshot
#   def remember; @history << snapshot; end
#   def undo; @history.pop.try { |m| restore(m) }; end
#   # Wrappers call remember before mutating.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   In production DBs, transactions use logs, not "full object snapshots".
#   Why? And when is Memento still a good fit?
# SOLUTION 3:
#   DB snapshots are huge; databases log mutations (redo/undo logs) so
#   rollback is a small set of inverse operations, not a full state copy.
#   Memento is a good fit at the application-object level when state is
#   small, or when you want undo without designing per-operation inverses.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
