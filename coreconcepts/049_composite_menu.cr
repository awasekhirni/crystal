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
#   A restaurant menu has sections ("Drinks", "Main Courses"), which have
#   items AND subsections ("Drinks > Wine"). The composite pattern lets a
#   menu behave like an item for traversal purposes — you "print" the whole
#   menu the same way you'd print one section.
#
# SETUP:
#   crystal run 049_composite_menu.cr
# =============================================================================

# Module `MenuComponent`.
module MenuComponent
  # Return the result of `display`.
  abstract def display(indent : Int32 = 0) : String
  # Return the result of `price`.
  abstract def price : Float64
end

# Concrete class `MenuItem`.
class MenuItem
  include MenuComponent
  def initialize(@name : String, @price : Float64, @vegetarian : Bool = false); end
  # Return the result of `price`.
  def price : Float64; @price; end
  # Return the result of `display`.
  def display(indent : Int32 = 0) : String
    mark = @vegetarian ? " (v)" : ""
    "#{"  " * indent}- #{@name}#{mark} $#{@price}"
  end
end

# Concrete class `MenuCategory`.
class MenuCategory
  include MenuComponent
  def initialize(@name : String); end
  @items = [] of MenuComponent

  # Add an element and return self for chaining.
  def add(item : MenuComponent) : MenuCategory
    @items << item
    self
  end

  # Composite sum of children prices (matches Composite semantics).
  def price : Float64; @items.sum(&.price); end

  # Return the result of `display`.
  def display(indent : Int32 = 0) : String
    lines = ["#{"  " * indent} #{@name}"]
    @items.each { |i| lines << i.display(indent + 1) }
    lines.join('\n')
  end
end

# ---- Demonstration ----------------------------------------------------------
drinks = MenuCategory.new("Drinks")
drinks.add(MenuItem.new("Cola", 2.5))
wine = MenuCategory.new("Wine")
wine.add(MenuItem.new("Red", 6.0))
wine.add(MenuItem.new("White", 5.0))
drinks.add(wine)

main = MenuCategory.new("Main Courses")
main.add(MenuItem.new("Pasta", 12.0, true))
main.add(MenuItem.new("Steak", 22.0))

menu = MenuCategory.new("Dinner Menu")
menu.add(drinks).add(main)
puts menu.display

# =============================================================================
# EXERCISE 1
#   Add "vegetarian filter" that returns only veg items (recursive).
# SOLUTION 1:
#   # MenuItem: vegetarian? returns @vegetarian
#   # MenuCategory: veg_only(prefix = "") -> Array(String)
#   # iterate children; for MenuItem check vegetarian; for MenuCategory recurse.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Give price semantics for "discounted category" as a separate composite.
# SOLUTION 2:
#   class DiscountCategory < MenuCategory
#     def initialize(name, @factor); super(name); end
#     def price : Float64; super  (1 - @factor); end
#   end
#   # Only overrides price; display and add inherit unchanged.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does "price" feel semantically odd on a category? What's the fix?
# SOLUTION 3:
#   A category's "price" is a sum, which may not represent business truth
#   (a category is not purchasable). Better: keep `price` on MenuItem only,
#   and put `total_price` on MenuCategory. Slight violation of "uniform
#   interface", but more honest. Composite is a technique, not a religion.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
