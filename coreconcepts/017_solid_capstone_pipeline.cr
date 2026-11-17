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
#   Five rules (SOLID) all working together in one small pipeline. Each
#   stage has one job (SRP), is swappable without edits (OCP), respects
#   parent promises (LSP), uses small interfaces (ISP), and depends on
#   abstractions (DIP).
#
# SETUP:
#   crystal run 017_solid_capstone_pipeline.cr
# =============================================================================

# --- Abstractions (DIP: everyone depends on these) --------------------------
module Stage
  # Return the result of `process`.
  abstract def process(input : String) : String
end

# Module `Validator`.
module Validator
  # Return the result of `validate`.
  abstract def validate(input : String) : Bool
end

# --- Concrete stages (SRP: one job each; OCP: add new without edits) -------
class TrimStage
  include Stage
  # Return the result of `process`.
  def process(input : String) : String; input.strip; end
end

# Concrete class `UpperStage`.
class UpperStage
  include Stage
  # Return the result of `process`.
  def process(input : String) : String; input.upcase; end
end

# Concrete class `AppendStage`.
class AppendStage
  include Stage
  def initialize(@suffix : String); end
  # Return the result of `process`.
  def process(input : String) : String; input + @suffix; end
end

# --- A validator with a small interface (ISP) -------------------------------
class NonEmptyValidator
  include Validator
  # Return the result of `validate`.
  def validate(input : String) : Bool; !input.strip.empty?; end
end

# --- Composer: uses abstractions, open for extension (OCP), testable (DIP) --
class Pipeline
  def initialize(@stages : Array(Stage), @validator : Validator); end

  # Execute the template-method pipeline and return the result.
  def run(input : String) : String?
    return nil unless @validator.validate(input)
    @stages.reduce(input) { |acc, stage| stage.process(acc) }
  end
end

# --- The only "LSP-flavored" nuance: all stages honor Stage contract -------
# Every Stage returns a String for any String input (no raising unexpectedly,
# no narrower return type). Substitution is safe.

# ---- Demonstration ----------------------------------------------------------
p = Pipeline.new(
  [TrimStage.new, UpperStage.new, AppendStage.new("!")] of Stage,
  NonEmptyValidator.new
)
puts p.run("  hello  ")   # => HELLO!
puts p.run("   ").inspect # => nil (rejected by validator)

# =============================================================================
# EXERCISE 1
#   Add a ReverseStage without editing Pipeline.
# SOLUTION 1:
#   class ReverseStage
#     include Stage
#     def process(input : String) : String; input.reverse; end
#   end
#   Pipeline.new([ReverseStage.new] as Array(Stage), NonEmptyValidator.new)
#           .run("abc")   # => "cba"
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a MaxLenValidator (reject > 10 chars) and inject it.
# SOLUTION 2:
#   class MaxLenValidator
#     include Validator
#     def validate(input : String) : Bool; input.size <= 10; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Map each class in this file to exactly one SOLID letter and justify.
# SOLUTION 3:
#   - SRP: TrimStage, UpperStage, AppendStage each do one thing.
#   - OCP: Pipeline closed for modification; add stages to extend.
#   - LSP: Every Stage honors "String -> String" without surprises.
#   - ISP: Validator is a tiny interface; stages don't implement it.
#   - DIP: Pipeline depends on Stage & Validator, not on concrete classes.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
