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
#   Two furniture stores: Victorian and Modern. Each sells a chair and a
#   sofa. You must NOT mix a Victorian chair with a Modern sofa — they
#   clash. Abstract Factory = one factory per "family", guaranteeing matching
#   pieces.
#
# SETUP:
#   crystal run 027_abstract_factory_ui.cr
# =============================================================================

# --- Abstract products -------------------------------------------------------
module Button
  # Render the receiver to a String representation.
  abstract def render : String
end

# Module `Checkbox`.
module Checkbox
  # Render the receiver to a String representation.
  abstract def render : String
end

# --- Concrete products (family 1: Light theme) ------------------------------
class LightButton
  include Button
  # Render the receiver to a String representation.
  def render : String; "[ Light Button ]"; end
end

# Concrete class `LightCheckbox`.
class LightCheckbox
  include Checkbox
  # Render the receiver to a String representation.
  def render : String; "[ ] Light Checkbox"; end
end

# --- Concrete products (family 2: Dark theme) -------------------------------
class DarkButton
  include Button
  # Render the receiver to a String representation.
  def render : String; "( Dark Button )"; end
end

# Concrete class `DarkCheckbox`.
class DarkCheckbox
  include Checkbox
  # Render the receiver to a String representation.
  def render : String; "[x] Dark Checkbox"; end
end

# --- Abstract factory --------------------------------------------------------
abstract class UIFactory
  # Return the result of `create_button`.
  abstract def create_button : Button
  # Return the result of `create_checkbox`.
  abstract def create_checkbox : Checkbox
end

# Concrete class `LightFactory` -- extends UIFactory.
class LightFactory < UIFactory
  # Return the result of `create_button`.
  def create_button : Button; LightButton.new; end
  # Return the result of `create_checkbox`.
  def create_checkbox : Checkbox; LightCheckbox.new; end
end

# Concrete class `DarkFactory` -- extends UIFactory.
class DarkFactory < UIFactory
  # Return the result of `create_button`.
  def create_button : Button; DarkButton.new; end
  # Return the result of `create_checkbox`.
  def create_checkbox : Checkbox; DarkCheckbox.new; end
end

# --- Client: only knows the abstract factory --------------------------------
def render_form(factory : UIFactory) : Nil
  puts factory.create_button.render
  puts factory.create_checkbox.render
end

# ---- Demonstration ----------------------------------------------------------
render_form(LightFactory.new)
puts "---"
render_form(DarkFactory.new)

# =============================================================================
# EXERCISE 1
#   Add a HighContrastFactory with HighContrastButton and HighContrastCheckbox.
# SOLUTION 1:
#   class HighContrastButton; include Button
#     def render; "[HIGH Button]"; end; end
#   class HighContrastCheckbox; include Checkbox
#     def render; "[HIGH Checkbox]"; end; end
#   class HighContrastFactory < UIFactory
#     def create_button : Button; HighContrastButton.new; end
#     def create_checkbox : Checkbox; HighContrastCheckbox.new; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `TextField` product to the family. What must change?
# SOLUTION 2:
#   Add TextField module, LightTextField, DarkTextField, HighContrastTextField,
#   and add `abstract def create_textfield : TextField` to UIFactory plus
#   implementations in each factory. Clients that don't need textfields are
#   unaffected — this is the cost of Abstract Factory when the family grows.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain why mixing LightFactory-created buttons with DarkFactory-created
#   checkboxes is normally impossible.
# SOLUTION 3:
#   The client holds only one factory at a time (a UIFactory). All created
#   products therefore belong to the same concrete family. By convention, a
#   factory's products are family-aligned; the type system prevents calling
#   create_button on LightFactory and create_checkbox on DarkFactory unless
#   you deliberately keep two factory instances, which is a usage error the
#   pattern discourages.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
