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
#   Your app uses "Payment" with method `pay`. A third-party SDK only offers
#   `charge(amount_cents, currency)`. You wrap that SDK in an Adapter so the
#   rest of your code keeps talking in "Payment" — and if you swap SDKs
#   later, only the adapter changes.
#
# SETUP:
#   crystal run 043_adapter_third_party_api.cr
# =============================================================================

# --- Your domain interface --------------------------------------------------
module PaymentGateway
  # Return the result of `pay`.
  abstract def pay(amount : Float64, currency : String) : String
end

# --- Third-party SDK (pretend: cannot modify) ------------------------------
module FastChargeSdk
  # Concrete class `Client`.
  class Client
    # Return the result of `charge`.
    def charge(amount_cents : Int64, iso_currency : String) : Tuple(Bool, String)
      {true, "txn-#{amount_cents}-#{iso_currency}"}
    end
  end
end

# --- Adapter: normalizes inputs, converts units, maps error states ---------
class FastChargeAdapter
  include PaymentGateway
  def initialize(@client : FastChargeSdk::Client = FastChargeSdk::Client.new); end

  # Return the result of `pay`.
  def pay(amount : Float64, currency : String) : String
    cents = (amount * 100).round.to_i64
    ok, ref = @client.charge(cents, currency.upcase)
    raise "charge failed: #{ref}" unless ok
    "Paid #{amount} #{currency} -> #{ref}"
  end
end

# --- Client -----------------------------------------------------------------
def checkout(gateway : PaymentGateway) : Nil
  puts gateway.pay(49.99, "usd")
end

# ---- Demonstration ----------------------------------------------------------
checkout(FastChargeAdapter.new)

# =============================================================================
# EXERCISE 1
#   Add a `refund` path in your domain interface; implement it in the
#   adapter with a "negative charge" if the SDK has no refund method.
# SOLUTION 1:
#   module PaymentGateway
#     abstract def pay(amount : Float64, currency : String) : String
#     abstract def refund(amount : Float64, currency : String) : String
#   end
#   # In adapter:
#   def refund(amount, currency)
#     ok, ref = @client.charge(-(amount  100).round.to_i64, currency.upcase)
#     raise "refund failed: #{ref}" unless ok
#     "Refunded #{amount} #{currency}"
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a StripeSdkAdapter (pretend StripeSdk has `create_charge`) without
#   editing domain code.
# SOLUTION 2:
#   (Define StripeSdk::Client#create_charge.) Then a new adapter that
#   includes PaymentGateway and calls create_charge. checkout() unchanged.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Where should unit conversion live (adapter, domain, or SDK)? Why?
# SOLUTION 3:
#   In the adapter. The domain should speak "dollars" (business language);
#   the SDK speaks "cents" (transport). The adapter is a boundary object and
#   is the only place with permission to know both worlds' details. Putting
#   unit conversion in the domain leaks transport concerns; putting it in the
#   SDK is impossible (we don't own it).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
