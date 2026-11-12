# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:Polymorphism - poly means many, morphism for forms. many forms. call the same
# method name on different object and get behavior appropriate to each. Paying with cash, card or phone all "pay" they use
# the same button, but different internals.


module PaymentMethod
  abstract def pay(amount : Float64) : String
end


class CashPayment
  include PaymentMethod

  def pay(amount : Float64) : String
    "Paid $#{amount} with cash"
  end
end

class CardPayment
  include PaymentMethod

  def initialize(@last_four : String); end

  def pay(amount : Float64) : String
    "Charged $#{amount} to card ending #{@last_four}"
  end
end

class WalletPayment
  include PaymentMethod

  def initialize(@wallet_id : String); end

  def pay(amount : Float64) : String
    "Deducted $#{amount} from wallet #{@wallet_id}"
  end
end

# Client is polymorphic: it doesn't know or care which concrete type.
def checkout(payments : Array(PaymentMethod), total : Float64)
  payments.each { |p| puts p.pay(total) }
end

# ---- Demonstration ----------------------------------------------------------
checkout([CashPayment.new, CardPayment.new("4242"), WalletPayment.new("W-1")], 19.99)

# =============================================================================
# EXERCISE 1
#   Add a `CryptoPayment` that simulates a fee.
# SOLUTION 1:
#   class CryptoPayment
#     include PaymentMethod
#     def pay(amount : Float64) : String
#       fee = amount * 0.01
#       "Paid $#{amount} crypto (fee $#{fee})"
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Select the method at runtime based on a symbol.
# SOLUTION 2:
#   def pick(kind : Symbol) : PaymentMethod
#     case kind
#     when :cash   then CashPayment.new
#     when :card   then CardPayment.new("0000")
#     when :wallet then WalletPayment.new("W-2")
#     else raise "unknown"
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a `refund` method; ensure each type returns a message.
# SOLUTION 3:
#   Add `abstract def refund(amount : Float64) : String` in the module,
#   implement in each class, e.g. "Refunded $#{amount} to card ...".
# =============================================================================
#
