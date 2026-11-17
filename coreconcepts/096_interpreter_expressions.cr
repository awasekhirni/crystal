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
#   A tiny calculator: "3 + 4  2" — we can model each number and each
#   operation as objects that know how to "interpret" themselves. Interpreter
#   = represent a language's syntax as a class hierarchy; interpret recursively.
#
# SETUP:
#   crystal run 096_interpreter_expressions.cr
# =============================================================================

# --- Expression interface --------------------------------------------------
module Expr
  # Evaluate this expression against `env` and return the result.
  abstract def eval(env : Hash(String, Int32)) : Int32
  # Append this object's String representation to `io`.
  abstract def to_s(io : IO) : Nil
end

# --- Terminals ------------------------------------------------------------
class Num
  include Expr
  def initialize(@value : Int32); end
  # Evaluate this expression against `env` and return the result.
  def eval(env : Hash(String, Int32)) : Int32; @value; end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << @value; end
end

# Concrete class `Var`.
class Var
  include Expr
  def initialize(@name : String); end
  # Evaluate this expression against `env` and return the result.
  def eval(env : Hash(String, Int32)) : Int32
    env.fetch(@name) { raise "undefined var #{@name}" }
  end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << @name; end
end

# --- Non-terminals (operators) -------------------------------------------
abstract class BinaryExpr
  include Expr
  def initialize(@left : Expr, @right : Expr); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil
    io << "(" << @left << " " << symbol << " " << @right << ")"
  end
  # Return the result of `symbol`.
  abstract def symbol : String
end

# Concrete class `Add` -- extends BinaryExpr.
class Add < BinaryExpr
  # Return the result of `symbol`.
  def symbol : String; "+"; end
  # Evaluate this expression against `env` and return the result.
  def eval(env : Hash(String, Int32)) : Int32
    @left.eval(env) + @right.eval(env)
  end
end

# Concrete class `Mul` -- extends BinaryExpr.
class Mul < BinaryExpr
  # Return the result of `symbol`.
  def symbol : String; ""; end
  # Evaluate this expression against `env` and return the result.
  def eval(env : Hash(String, Int32)) : Int32
    @left.eval(env) + @right.eval(env)
  end
end

# --- "3 + x  2" --------------------------------------------------------
expr = Add.new(
  Num.new(3),
  Mul.new(Var.new("x"), Num.new(2))
)

# ---- Demonstration ----------------------------------------------------------
env = {"x" => 5}
puts "#{expr} = #{expr.eval(env)}"   # (3 + (x  2)) = 13
env["x"] = 10
puts "#{expr} = #{expr.eval(env)}"   # 23

# =============================================================================
# EXERCISE 1
#   Add Sub and Div expressions.
# SOLUTION 1:
#   class Sub < BinaryExpr; def symbol; "-"; end
#     def eval(env); @left.eval(env) - @right.eval(env); end
#   end
#   class Div < BinaryExpr; def symbol; "/"; end
#     def eval(env)
#       r = @right.eval(env)
#       raise "div by zero" if r == 0
#       @left.eval(env) // r
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add assignment: SetExpr("y", value) that updates env.
# SOLUTION 2:
#   class SetExpr
#     include Expr
#     def initialize(@name, @expr : Expr); end
#     def eval(env); v = @expr.eval(env); env[@name] = v; v; end
#     def to_s(io); io << @name << " = " << @expr; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   When does Interpreter become a bad fit? Give a concrete sign.
# SOLUTION 3:
#   When the grammar is large or changes often — each rule becomes a class
#   and eval/simplify/print methods proliferate. Concretely: if you have more
#   than a couple dozen productions or need parsing tooling, switch to a
#   grammar-driven parser + AST + visitor. Interpreter is great for tiny
#   embedded languages and rule engines.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
