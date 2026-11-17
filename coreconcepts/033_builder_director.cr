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
#   A head chef (Director) knows the standard recipes: "make a small burger
#   with fries", "make a large salad". They don't cook themselves — they
#   hand step-by-step instructions to a line cook (Builder). Same recipes
#   can produce different cuisines if a different cook is used.
#
# SETUP:
#   crystal run 033_builder_director.cr
# =============================================================================

# --- Product ----------------------------------------------------------------
class Meal
  getter items = [] of String
  # Add an element and return self for chaining.
  def add(item : String) : Nil; @items << item; end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "Meal(" << @items.join(", ") << ")"; end
end

# --- Builder interface ------------------------------------------------------
abstract class MealBuilder
  # Return the result of `add_main`.
  abstract def add_main : Nil
  # Return the result of `add_side`.
  abstract def add_side : Nil
  # Return the result of `add_drink`.
  abstract def add_drink : Nil
  # Return the result of `add_dessert`.
  abstract def add_dessert : Nil
  # Return the result of `meal`.
  abstract def meal : Meal
end

# --- Concrete builders ------------------------------------------------------
class BurgerMealBuilder < MealBuilder
  @meal = Meal.new
  # Return the result of `add_main`.
  def add_main : Nil; @meal.add("burger"); end
  # Return the result of `add_side`.
  def add_side : Nil; @meal.add("fries"); end
  # Return the result of `add_drink`.
  def add_drink : Nil; @meal.add("soda"); end
  # Return the result of `add_dessert`.
  def add_dessert : Nil; @meal.add("cookie"); end
  # Return the result of `meal`.
  def meal : Meal; @meal; end
end

# Concrete class `SaladMealBuilder` -- extends MealBuilder.
class SaladMealBuilder < MealBuilder
  @meal = Meal.new
  # Return the result of `add_main`.
  def add_main : Nil; @meal.add("grilled chicken salad"); end
  # Return the result of `add_side`.
  def add_side : Nil; @meal.add("bread"); end
  # Return the result of `add_drink`.
  def add_drink : Nil; @meal.add("sparkling water"); end
  # Return the result of `add_dessert`.
  def add_dessert : Nil; @meal.add("fruit cup"); end
  # Return the result of `meal`.
  def meal : Meal; @meal; end
end

# --- Director: encapsulates recipes ----------------------------------------
class MealDirector
  # Return the result of `build_kids_meal`.
  def build_kids_meal(builder : MealBuilder) : Meal
    builder.add_main
    builder.add_side
    builder.add_drink
    builder.meal
  end

  # Return the result of `build_full_meal`.
  def build_full_meal(builder : MealBuilder) : Meal
    builder.add_main
    builder.add_side
    builder.add_drink
    builder.add_dessert
    builder.meal
  end
end

# ---- Demonstration ----------------------------------------------------------
director = MealDirector.new
puts director.build_kids_meal(BurgerMealBuilder.new)
puts director.build_full_meal(SaladMealBuilder.new)

# =============================================================================
# EXERCISE 1
#   Add a VegetarianMealBuilder without touching Director or Meal.
# SOLUTION 1:
#   class VegetarianBuilder < MealBuilder
#     @meal = Meal.new
#     def add_main; @meal.add("veggie burger"); end
#     def add_side; @meal.add("salad"); end
#     def add_drink; @meal.add("juice"); end
#     def add_dessert; @meal.add("sorbet"); end
#     def meal; @meal; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "deluxe meal" recipe to the director.
# SOLUTION 2:
#   def build_deluxe_meal(b : MealBuilder) : Meal
#     b.add_main; b.add_side; b.add_side; b.add_drink; b.add_dessert; b.meal
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   When is Director over-engineering?
# SOLUTION 3:
#   When recipes are one-off, and callers can reasonably chain builder
#   methods themselves. The Director pays off when (a) multiple recipes
#   exist, (b) recipes are business concepts the domain must enforce, or
#   (c) you want to prevent callers from forgetting required steps.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
