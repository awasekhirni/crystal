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
#   Compiling code is many steps: lex, parse, type-check, optimize, emit.
#   A user just runs `compile(source)`. The facade ties the steps together;
#   each step is an independent class if advanced users need them.
#
# SETUP:
#   crystal run 056_facade_compiler.cr
# =============================================================================

# Concrete class `Lexer`.
class Lexer
  # Return the result of `tokenize`.
  def tokenize(src : String) : Array(String); src.split(' '); end
end

# Concrete class `Parser`.
class Parser
  # Parse `raw` into a list of typed rows.
  def parse(tokens : Array(String)) : String; "AST(#{tokens.join(",")})"; end
end

# Concrete class `TypeChecker`.
class TypeChecker
  # Return the result of `check`.
  def check(ast : String) : String; "typed:#{ast}"; end
end

# Concrete class `Optimizer`.
class Optimizer
  # Return the result of `optimize`.
  def optimize(ast : String) : String; "optimized:#{ast}"; end
end

# Concrete class `CodeEmitter`.
class CodeEmitter
  # Return the result of `emit`.
  def emit(ast : String) : String; "binary<#{ast}>"; end
end

# --- Facade ----------------------------------------------------------------
class CompilerFacade
  def initialize
    @lexer = Lexer.new
    @parser = Parser.new
    @checker = TypeChecker.new
    @optimizer = Optimizer.new
    @emitter = CodeEmitter.new
  end

  # One method hides all steps.
  def compile(source : String) : String
    tokens = @lexer.tokenize(source)
    ast = @parser.parse(tokens)
    typed = @checker.check(ast)
    optimized = @optimizer.optimize(typed)
    @emitter.emit(optimized)
  end

  # Granular escape hatches for advanced users.
  def tokenize_only(src : String) : Array(String); @lexer.tokenize(src); end
  # Return the result of `optimize_only`.
  def optimize_only(src : String) : String
    @optimizer.optimize(@parser.parse(@lexer.tokenize(src)))
  end
end

# ---- Demonstration ----------------------------------------------------------
puts CompilerFacade.new.compile("let x = 1")

# =============================================================================
# EXERCISE 1
#   Add a `debug_compile` that returns the intermediate artifact from
#   each step.
# SOLUTION 1:
#   def debug_compile(src : String) : Hash(String, String)
#     tokens = @lexer.tokenize(src)
#     ast = @parser.parse(tokens)
#     typed = @checker.check(ast)
#     opt = @optimizer.optimize(typed)
#     { "tokens" => tokens.join(","), "ast" => ast,
#       "typed" => typed, "opt" => opt,
#       "bin" => @emitter.emit(opt) }
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "verbose" constructor flag that prints each stage.
# SOLUTION 2:
#   def initialize(@verbose = false); ... end
#   # After each stage: puts "stage X: #{result}" if @verbose
# =============================================================================

# =============================================================================
# EXERCISE 3
#   If the pipeline grows to 12 steps, what does Facade NOT solve?
# SOLUTION 3:
#   It doesn't help change the pipeline — swapping/removing a step still
#   requires editing the facade (OCP concern). For that, switch to a Pipeline
#   abstraction with `Array(Stage)` — same idea as Composite / Chain of
#   Responsibility. Facade is for the client view; pipeline architecture
#   is for internal flexibility.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
