# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Interface Seggregation Principle many small contracts beat one giant one
# dont force a simple old printer to also scan and fax just because a fancy all in one printer can
#

#ISP-compliant - three small modules
#
module Printable
  abstract def print_doc(doc : String) : String
end

module Scannable
  abstract def scan_doc : String
end

module Faxable
  abstract def fax_doc(doc : String) : String
end

# Simple printer implements ONLY what it needs.
class SimplePrinter
  include Printable
  def print_doc(doc : String) : String
    "Printed: #{doc}"
  end
end

# All-in-one implements all three, but nothing is forced on SimplePrinter.
class AllInOne
  include Printable
  include Scannable
  include Faxable

  def print_doc(doc : String) : String; "Printed: #{doc}"; end
  def scan_doc : String; "Scanned page"; end
  def fax_doc(doc : String) : String; "Faxed: #{doc}"; end
end

# Clients ask only for what they use — compile-time safe because Crystal
# resolves the type. Here we accept Printable for printing.
def print_all(items : Array(Printable), doc : String)
  items.each { |i| puts i.print_doc(doc) }
end

# ---- Demonstration ----------------------------------------------------------
print_all([SimplePrinter.new, AllInOne.new] of Printable, "hello.pdf")

# =============================================================================
# EXERCISE 1
#   Add a Scanner-only device (no printer) and use it in a scan_all helper.
# SOLUTION 1:
#   class PureScanner
#     include Scannable
#     def scan_doc : String; "Scanned (pure)"; end
#   end
#   def scan_all(items : Array(Scannable))
#     items.each { |i| puts i.scan_doc }
#   end
#   scan_all([PureScanner.new, AllInOne.new] as Array(Scannable))
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Refactor a "fat" module IPrinter (print/scan/fax) into the three above
#   and explain the benefit in one comment.
# SOLUTION 2:
#   The fat module forced SimplePrinter to define scan_doc/fax_doc or
#   include a stub, polluting its API and forcing recompilation whenever
#   any of the three contracts changed. ISP splits those axes.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a helper that accepts anything *both* Printable and Scannable.
# SOLUTION 3:
#   def copy(doc : String, dev : Printable & Scannable)
#     dev.print_doc(dev.scan_doc)
#   end
#   (Crystal supports intersection types via `&` in type restrictions.)
# =====================================================================
