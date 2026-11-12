# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Liskov substition principle (LSP)subsclasses must be usable anywhere their parent is, without any surprises.
# A statement like any bird can fly, does not hold true for penguins. they do belong to the bird class, but they exhibit another behaviour.
# if your code says "any bird can fly", then a penguin that claims to be a bird should not crach when someone calls fly method.

# --- wrong: Penguin breaks the "Bird fly" contract ---------------------------
#
#   class Bird; def fly; "flying"; end; end
#   class Penguin < Bird
#     def fly; raise "Penguins can't fly"; end   # LSP violation
#   end

# --- correct approach : split the abstraction -------------------------------------------
# "Bird" is not the right level of abstraction. Introduce "Flying" as a
# separate capability, and let a Bird exist without it.
class Bird
  getter name : String
  def initialize(@name : String); end
  def describe : String; "#{@name} the bird"; end
end

module Flying
  abstract def fly : String
end

class Sparrow < Bird
  include Flying
  def fly : String; "#{@name} flutters up"; end
end

class Penguin < Bird
  # No Flying mixed in — callers can't accidentally fly a penguin.
  def swim : String; "#{@name} swims"; end
end

# Client only requires Flying where flying is needed — substitution safe.
def send_flying(birds : Array(Flying))
  birds.each { |b| puts b.fly }
end

# ---- Demonstration ----------------------------------------------------------
# Use `.as(Type)` for explicit type casting in Crystal
birds : Array(Bird) = [Sparrow.new("Tweety").as(Bird), Penguin.new("Pingu").as(Bird)]
birds.each { |b| puts b.describe }

send_flying([Sparrow.new("Sunny").as(Flying)])

# =============================================================================
# EXERCISE 1
#   Add a Duck that both flies and swims.
# SOLUTION 1:
#   module Swimming; abstract def swim : String; end
#   class Duck < Bird
#     include Flying
#     include Swimming
#     def fly : String; "#{@name} quacks through the air"; end
#     def swim : String; "#{@name} paddles"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Write a test-style check that replaces a Sparrow with an (LSP-safe) Duck
#   without changing behavior of send_flying.
# SOLUTION 2:
#   send_flying([Duck.new("Donald").as(Flying)])  # both respond to fly
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Identify the LSP anti-pattern in the "bad" snippet above.
# SOLUTION 3:
#   The subclass *strengthens preconditions* (raising on `fly`) and therefore
#   weakens guarantees promised by Bird. Callers substituting Penguin for Bird
#   receive an exception they did not expect. Instead, model capabilities
#   (Flying, Swimming) as separate abstractions and only let classes mix in
#   what they honestly provide.
# =============================================================================
#
#
