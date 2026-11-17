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
#   A cart's total price depends on the customer segment: regular, VIP,
#   seasonal sale, bulk. Strategy = each pricing rule is an object; swap it
#   without touching the cart.
#
# SETUP:
#   crystal run 089_strategy_pricing.cr
# =============================================================================

# Module `Pricing`.
module Pricing
  # Compute and return the total.
  abstract def total(items : Array(Item)) : Float64
  # Return a short human-readable label for this strategy.
  abstract def label : String
end

record Item, name : String, unit_price : Float64, qty : Int32 do
  # Return this line item's subtotal (unit_price * qty).
  def subtotal : Float64; unit_price * qty; end
end

# Concrete class `RegularPricing`.
class RegularPricing
  include Pricing
  # Return a short human-readable label for this strategy.
  def label : String; "regular"; end
  # Compute and return the total.
  def total(items : Array(Item)) : Float64; items.sum(&.subtotal); end
end

# Concrete class `VipPricing`.
class VipPricing
  include Pricing
  def initialize(@discount : Float64 = 0.10); end
  # Return a short human-readable label for this strategy.
  def label : String; "vip (#{(@discount * 100).round}% off)"; end
  # Compute and return the total.
  def total(items : Array(Item)) : Float64
    items.sum(&.subtotal) * (1.0 - @discount)
  end
end

# Concrete class `BulkPricing`.
class BulkPricing
  include Pricing
  def initialize(@threshold : Int32 = 10, @discount : Float64 = 0.20); end
  # Return a short human-readable label for this strategy.
  def label : String; "bulk (>=#{@threshold} units, #{(@discount * 100).round}% off)"; end
  # Compute and return the total.
  def total(items : Array(Item)) : Float64
    sum = 0.0
    items.each do |item|
      line = item.subtotal
      line = (1.0 - @discount) if item.qty >= @threshold
      sum += line
    end
    sum
  end
end

# Concrete class `Cart`.
class Cart
  def initialize(@pricing : Pricing); end
  # Return the result of `pricing=`.
  def pricing=(@pricing : Pricing); end
  # Compute and return the total.
  def total(items : Array(Item)) : String
    "$#{@pricing.total(items).round(2)} (#{@pricing.label})"
  end
end

# ---- Demonstration ----------------------------------------------------------
items = [Item.new("widget", 9.99, 12), Item.new("gadget", 49.99, 1)]
cart = Cart.new(RegularPricing.new)
puts cart.total(items)
cart.pricing = VipPricing.new
puts cart.total(items)
cart.pricing = BulkPricing.new
puts cart.total(items)

# =============================================================================
# EXERCISE 1
#   Add "FreeShippingPricing" that subtracts a fixed shipping fee.
# SOLUTION 1:
#   class FreeShippingPricing
#     include Pricing
#     def initialize(@shipping_fee : Float64 = 9.99); end
#     def label; "free shipping"; end
#     def total(items); items.sum(&.subtotal) - @shipping_fee; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Combine strategies: VIP then bulk (multiplicative).
# SOLUTION 2:
#   class CompositePricing
#     include Pricing
#     def initialize(@a : Pricing, @b : Pricing); end
#     def label; "#{@a.label} + #{@b.label}"; end
#     def total(items); @b.total(items)  (@a.total(items) / items.sum(&.subtotal)); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does pricing logic in a Strategy age better than conditionals in Cart?
# SOLUTION 3:
#   Cart's job is cart behavior (adding, listing items, calculating totals
#   via a policy). Pricing rules change more often and vary by context
#   (region, campaign). Isolating them in Strategy lets pricing managers add
#   new rules without recompiling the cart's tests; conditionals invite
#   duplicated rules across cart/checkout/invoice.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
