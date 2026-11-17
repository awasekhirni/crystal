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
#   Imagine two "pizza makers": one decides on a single pizza (Factory
#   Method), the other makes sure the pizza AND its drink come from the same
#   brand (Abstract Factory). Both hide construction; Abstract Factory groups
#   several products from one family.
#
# SETUP:
#   crystal run 030_abstract_factory_vs_fm.cr
# =============================================================================

# ---- Factory Method side (single product per creator) ----------------------
module Pizza
  # Return the result of `bake`.
  abstract def bake : String
end

# Concrete class `Margherita`.
class Margherita; include Pizza
  # Return the result of `bake`.
  def bake : String; "Margherita baked"; end; end
# Concrete class `Pepperoni`.
class Pepperoni; include Pizza
  # Return the result of `bake`.
  def bake : String; "Pepperoni baked"; end; end

# Abstract class `PizzaCreator`.
abstract class PizzaCreator
  # Return the result of `create_pizza`.
  abstract def create_pizza : Pizza
  # Return the result of `order`.
  def order : String; "Order: #{create_pizza.bake}"; end
end

# Concrete class `MargheritaCreator` -- extends PizzaCreator.
class MargheritaCreator < PizzaCreator
  # Return the result of `create_pizza`.
  def create_pizza : Pizza; Margherita.new; end
end
# Concrete class `PepperoniCreator` -- extends PizzaCreator.
class PepperoniCreator < PizzaCreator
  # Return the result of `create_pizza`.
  def create_pizza : Pizza; Pepperoni.new; end
end

# ---- Abstract Factory side (multiple related products) --------------------
module Drink
  # Return the result of `pour`.
  abstract def pour : String
end

# Concrete class `Cola`.
class Cola; include Drink
  # Return the result of `pour`.
  def pour : String; "Cola poured"; end; end
# Concrete class `Lemonade`.
class Lemonade; include Drink
  # Return the result of `pour`.
  def pour : String; "Lemonade poured"; end; end

# Abstract class `MealFactory`.
abstract class MealFactory
  # Return the result of `pizza`.
  abstract def pizza : Pizza
  # Return the result of `drink`.
  abstract def drink : Drink
end

# "Classic" family pairs Margherita + Cola.
class ClassicMealFactory < MealFactory
  # Return the result of `pizza`.
  def pizza : Pizza; Margherita.new; end
  # Return the result of `drink`.
  def drink : Drink; Cola.new; end
end

# "Fresh" family pairs Pepperoni + Lemonade.
class FreshMealFactory < MealFactory
  # Return the result of `pizza`.
  def pizza : Pizza; Pepperoni.new; end
  # Return the result of `drink`.
  def drink : Drink; Lemonade.new; end
end

# ---- Demonstration ----------------------------------------------------------
puts "Factory Method:"
puts MargheritaCreator.new.order
puts PepperoniCreator.new.order

puts "\nAbstract Factory:"
[ClassicMealFactory.new, FreshMealFactory.new].each do |f|
  puts "#{f.pizza.bake} + #{f.drink.pour}"
end

# =============================================================================
# EXERCISE 1
#   Add a "KidsMealFactory" with its own matching pair.
# SOLUTION 1:
#   Create a KidsPizza and KidsDrink and a KidsMealFactory. Existing client
#   code accepts it because it only sees MealFactory.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   For which of these two scenarios would Factory Method alone suffice?
# SOLUTION 2:
#   "Only pizzas exist, and drinks are handled elsewhere" — then Factory
#   Method on PizzaCreator suffices. Once pizzas and drinks must come from
#   the same family (e.g., branding rules), promote to Abstract Factory.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Rule of thumb in one sentence.
# SOLUTION 3:
#   Factory Method: one product interface, many concrete implementations.
#   Abstract Factory: MANY product interfaces, with each concrete factory
#   delivering a consistent family across all of them.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
