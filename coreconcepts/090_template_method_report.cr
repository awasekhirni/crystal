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
#   Every report has an order: title, body, footer. Some steps are common
#   (title style), some differ per report (what to include in body). Template
#   Method = the base class defines the order; subclasses fill in details.
#
# SETUP:
#   crystal run 090_template_method_report.cr
# =============================================================================

# --- Abstract base with the template method -------------------------------
abstract class Report
  # Template method: concrete and final in intent. Subclasses override only
  # the abstract hooks; they shouldn't override this method.
  def generate : String
    out = String::Builder.new
    out << header
    out << "\n"
    out << body
    out << "\n"
    out << footer
    out.to_s
  end

  # Hook methods with default behavior — subclasses may override.
  def header : String
    "== #{title} =="
  end

  # Return the result of `footer`.
  def footer : String
    "-- end of report --"
  end

  # Abstract: subclasses MUST provide these.
  abstract def title : String
  # Return the result of `body`.
  abstract def body : String
end

# --- Concrete reports -----------------------------------------------------
class SalesReport < Report
  def initialize(@data : Array(Tuple(String, Float64))); end
  # Return the result of `title`.
  def title : String; "Sales Report"; end
  # Return the result of `body`.
  def body : String
    @data.map { |(label, total)| "  #{label}: $#{total}" }.join("\n")
  end
end

# Concrete class `InventoryReport` -- extends Report.
class InventoryReport < Report
  def initialize(@items : Array(Tuple(String, Int32))); end
  # Return the result of `title`.
  def title : String; "Inventory Report"; end
  # Return the result of `body`.
  def body : String
    @items.map { |(name, qty)| "  #{name}: #{qty} units" }.join("\n")
  end
  # Override the hook for a fancier footer.
  def footer : String; "-- inventory check complete --"; end
end

# ---- Demonstration ----------------------------------------------------------
puts SalesReport.new([{"Q1", 1000.0}, {"Q2", 1200.0}]).generate
puts
puts InventoryReport.new([{"Widget", 120}, {"Gadget", 45}]).generate

# =============================================================================
# EXERCISE 1
#   Add a hook `after_body : String` (empty by default) called before footer.
# SOLUTION 1:
#   def after_body : String; ""; end
#   # In generate: out << after_body; out << "\n" unless after_body.empty?
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "summary" report that overrides body to be a one-liner.
# SOLUTION 2:
#   class SummaryReport < Report
#     def initialize(@title : String, @summary : String); end
#     def title; @title; end
#     def body; @summary; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Discuss trade-off: Template Method (inheritance) vs Strategy (composition).
# SOLUTION 3:
#   Template Method fixes the algorithm skeleton in the base class and lets
#   subclasses fill in steps — strong guidance, but inheritance-locked (you
#   need a subclass per variant). Strategy pulls each step into a composable
#   object; the algorithm becomes data, allowing runtime swaps. Template wins
#   when the skeleton is stable and variations are narrow; Strategy wins
#   when steps vary independently or need runtime swapping.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
