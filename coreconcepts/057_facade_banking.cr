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
#   Opening a bank account requires: identity verification, credit check,
#   account creation, and card issuance. From the customer's view it's
#   "open_account(name, ssn)". Facade hides the four services and their order.
#
# SETUP:
#   crystal run 057_facade_banking.cr
# =============================================================================

# Concrete class `IdentityService`.
class IdentityService
  # Return the result of `verify`.
  def verify(ssn : String) : Bool; ssn.size >= 4; end
end

# Concrete class `CreditService`.
class CreditService
  # Return the result of `check`.
  def check(ssn : String) : Int32; 720; end  # simulated score
end

# Concrete class `AccountService`.
class AccountService
  # Return the result of `create`.
  def create(name : String) : String; "acct-#{name.hash.abs}"; end
end

# Concrete class `CardService`.
class CardService
  # Return the result of `issue`.
  def issue(account : String) : String; "card-for-#{account}"; end
end

# --- Facade ----------------------------------------------------------------
class BankFacade
  def initialize
    @id = IdentityService.new
    @credit = CreditService.new
    @accounts = AccountService.new
    @cards = CardService.new
  end

  # One method, all services, with a single exit shape.
  def open_account(name : String, ssn : String) : Tuple(String, String)
    raise "identity failed" unless @id.verify(ssn)
    score = @credit.check(ssn)
    raise "credit too low (#{score})" if score < 600
    account = @accounts.create(name)
    card = @cards.issue(account)
    {account, card}
  end
end

# ---- Demonstration ----------------------------------------------------------
acct, card = BankFacade.new.open_account("Alice", "1234")
puts "opened #{acct}, card #{card}"

# =============================================================================
# EXERCISE 1
#   Add a `close_account(account)` that reverses services in order.
# SOLUTION 1:
#   class AccountService; def close(a); "closed #{a}"; end; end
#   class CardService; def cancel(c); "cancel #{c}"; end; end
#   # In facade:
#   def close_account(account, card)
#     puts @cards.cancel(card); puts @accounts.close(account)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Why is raising inside the facade risky? Suggest an alternative.
# SOLUTION 2:
#   Raises short-circuit and don't distinguish "identity failed" from "bank
#   rejected". A sealed result type is friendlier:
#   alias Result = {ok: Bool, code: String, account: String?}
#   Callers can branch on `code` without exceptions-as-flow.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with a Domain Service. When is "facade" the wrong word?
# SOLUTION 3:
#   A domain service expresses a business operation (open_account) and may
#   encapsulate real rules. A facade is primarily a usability wrapper over
#   existing services. If your class holds the business rules itself, it's
#   probably a domain service — the facade label misleads.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
