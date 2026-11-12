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

# ==-================================================================

# --- Abstractions (DIP: everyone depends on these) --------------------------
module Stage
  abstract def process(input : String) : String
end

module Validator
  abstract def validate(input : String) : Bool
end

# --- Concrete stages (SRP: one job each; OCP: add new without edits) -------
class TrimStage
  include Stage
  def process(input : String) : String; input.strip; end
end

class UpperStage
  include Stage
  def process(input : String) : String; input.upcase; end
end

class AppendStage
  include Stage
  def initialize(@suffix : String); end
  def process(input : String) : String; input + @suffix; end
end

# --- A validator with a small interface (ISP) -------------------------------
class NonEmptyValidator
  include Validator
  def validate(input : String) : Bool; !input.strip.empty?; end
end

# --- Composer: uses abstractions, open for extension (OCP), testable (DIP) --
class Pipeline
  def initialize(@stages : Array(Stage), @validator : Validator); end

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
