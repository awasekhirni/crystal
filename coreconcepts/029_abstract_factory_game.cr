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
#   In a fantasy game, the "Elf" faction has elf warriors and elf mages, the
#   "Orc" faction has orc warriors and orc mages. Enemies should always
#   match the faction — an Orc shouldn't be served by an elf healer.
#
# SETUP:
#   crystal run 029_abstract_factory_game.cr
# =============================================================================

# Module `Warrior`.
module Warrior
  # Return the result of `attack`.
  abstract def attack : String
end

# Module `Mage`.
module Mage
  # Return the result of `cast`.
  abstract def cast : String
end

# Module `Healer`.
module Healer
  # Return the result of `heal`.
  abstract def heal : String
end

# --- Elf family --------------------------------------------------------------
class ElfWarrior; include Warrior
  # Return the result of `attack`.
  def attack : String; "Elf: precise bow shot"; end; end
# Concrete class `ElfMage`.
class ElfMage; include Mage
  # Return the result of `cast`.
  def cast : String; "Elf: moonbeam"; end; end
# Concrete class `ElfHealer`.
class ElfHealer; include Healer
  # Return the result of `heal`.
  def heal : String; "Elf: nature's embrace"; end; end

# --- Orc family --------------------------------------------------------------
class OrcWarrior; include Warrior
  # Return the result of `attack`.
  def attack : String; "Orc: brutal axe swing"; end; end
# Concrete class `OrcMage`.
class OrcMage; include Mage
  # Return the result of `cast`.
  def cast : String; "Orc: bloodfire"; end; end
# Concrete class `OrcHealer`.
class OrcHealer; include Healer
  # Return the result of `heal`.
  def heal : String; "Orc: tribal salve"; end; end

# --- Abstract factory --------------------------------------------------------
abstract class FactionFactory
  # Return the result of `warrior`.
  abstract def warrior : Warrior
  # Return the result of `mage`.
  abstract def mage : Mage
  # Return the result of `healer`.
  abstract def healer : Healer
end

# Concrete class `ElfFactory` -- extends FactionFactory.
class ElfFactory < FactionFactory
  # Return the result of `warrior`.
  def warrior : Warrior; ElfWarrior.new; end
  # Return the result of `mage`.
  def mage : Mage; ElfMage.new; end
  # Return the result of `healer`.
  def healer : Healer; ElfHealer.new; end
end

# Concrete class `OrcFactory` -- extends FactionFactory.
class OrcFactory < FactionFactory
  # Return the result of `warrior`.
  def warrior : Warrior; OrcWarrior.new; end
  # Return the result of `mage`.
  def mage : Mage; OrcMage.new; end
  # Return the result of `healer`.
  def healer : Healer; OrcHealer.new; end
end

# --- Client: builds a balanced squad from ONE factory ----------------------
def assemble(faction : FactionFactory) : Nil
  puts faction.warrior.attack
  puts faction.mage.cast
  puts faction.healer.heal
end

# ---- Demonstration ----------------------------------------------------------
assemble(ElfFactory.new)
puts "---"
assemble(OrcFactory.new)

# =============================================================================
# EXERCISE 1
#   Add an "Undead" faction with all three unit types.
# SOLUTION 1:
#   (Three small classes + one UndeadFactory.) Then assemble(UndeadFactory.new).
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "mount" product to the family; explain impact on existing factories.
# SOLUTION 2:
#   Add `abstract def mount : Mount` to FactionFactory. Compilation of
#   existing factories fails until each implements create for Mount — this
#   is intentional: it forces family completeness.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare to Factory Method: what changes if we only had warriors?
# SOLUTION 3:
#   With only one product, Abstract Factory collapses to Factory Method.
#   Abstract Factory exists because of multiple related products that
#   must be created consistently. If you only need one product, use Factory
#   Method (or a simple factory) and skip the extra interface layer.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
