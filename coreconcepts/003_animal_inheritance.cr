# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed,Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Inheritance is child classes reuse and specialization of a parent class.
# each child follows the receipe in its own way.
#
#Parent class
class Animal
  getter name : String

  def initialize(@name : String); end
   #Hook method: default behavior; subclasses may override

  def speak : String
    "...."
  end

  #Template : uses polymorphic `speak` internally
  def introduce : String
    "I am #{@name} and I say #{speak}"
  end
end


#dog is specialization/sub class which inherits from main parent class
class Dog < Animal
  def speak : String
    "Woof Woof"
  end
end


#cat is specialization/subclass which inherits from main parent class
class Cat < Animal
  def speak : String
    "Meow"
  end
end


# Extending via super: subclass adds behavior on top of parent.
class Puppy < Dog
  def speak : String
    "#{super} (squeaky)"
  end
end

# ---- Demonstration ----------------------------------------------------------
[Animal.new("Generic"), Dog.new("Rex"), Cat.new("Tom"), Puppy.new("Bit")].each do |a|
  puts a.introduce
end

# =============================================================================
# EXERCISE 1
#   Add a Cow that says "Moo". Verify the introduce output.
# SOLUTION 1:
#   class Cow < Animal
#     def speak; "Moo"; end
#   end
#   puts Cow.new("Bessie").introduce  # => I am Bessie and I say Moo
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Make `Animal` abstract so it cannot be instantiated.
# SOLUTION 2:
#   abstract class Animal ... end
#   Then Animal.new("x") fails at compile time — that's the point.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a class method `Animal.create(kind : String)` that returns the right
#   subclass (this foreshadows Factory Method).
# SOLUTION 3:
#   def self.create(kind : String) : Animal
#     case kind
#     when "dog" then Dog.new("Rex")
#     when "cat" then Cat.new("Tom")
#     else raise "unknown: #{kind}"
#     end
#   end
# =============================================================================
