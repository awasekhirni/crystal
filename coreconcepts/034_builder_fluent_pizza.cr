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
#   A pizza builder that reads like a sentence: pizza.size("L").cheese.crust
#   ("thin").bake. Each call returns the builder, so you can chain. This is
#   the "fluent" flavor of the Builder pattern.
#
# SETUP:
#   crystal run 034_builder_fluent_pizza.cr
# =============================================================================

# Concrete class `Pizza`.
class Pizza
  getter size : String
  getter crust : String
  getter toppings : Array(String)

  def initialize(@size : String, @crust : String, @toppings : Array(String))
  end

  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "Pizza(#{@size}, #{@crust} crust, toppings: #{@toppings.join(", ")})"
  end
end

# Concrete class `PizzaBuilder`.
class PizzaBuilder
  @size : String = "M"
  @crust : String = "regular"
  @toppings = [] of String

  # Return the result of `size`.
  def size(s : String) : self
    raise "bad size" unless %w[S M L XL].includes?(s)
    @size = s
    self
  end

  # Return the result of `crust`.
  def crust(c : String) : self
    @crust = c
    self
  end

  # Return the result of `cheese`.
  def cheese : self
    @toppings << "cheese" unless @toppings.includes?("cheese")
    self
  end

  # Return the result of `pepperoni`.
  def pepperoni : self
    @toppings << "pepperoni" unless @toppings.includes?("pepperoni")
    self
  end

  # Return the result of `mushrooms`.
  def mushrooms : self
    @toppings << "mushrooms" unless @toppings.includes?("mushrooms")
    self
  end

  # Return the result of `bake`.
  def bake : Pizza
    raise "a pizza needs at least one topping" if @toppings.empty?
    Pizza.new(@size, @crust, @toppings.dup)
  end
end

# ---- Demonstration ----------------------------------------------------------
p = PizzaBuilder.new.size("L").crust("thin").cheese.pepperoni.bake
puts p

# =============================================================================
# EXERCISE 1
#   Add a `gluten_free` option that swaps the crust.
# SOLUTION 1:
#   def gluten_free : self
#     @crust = "gluten-free"
#     self
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `preset_vegetarian` macro-like method that chains several steps.
# SOLUTION 2:
#   def vegetarian : self
#     crust("thin").cheese.mushrooms
#   end
#   # PizzaBuilder.new.vegetarian.bake
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why must `bake` reject pizzas with no toppings?
# SOLUTION 3:
#   It's the last, single validation choke point. Validating at each setter
#   is error-prone and duplicates rules. Centralizing invariants in the
#   build step (or in Pizza's initialize) keeps the product always valid.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
