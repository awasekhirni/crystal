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
#   Opening a huge image is slow. The "virtual proxy" returns an object
#   immediately that looks like the image — and only loads the actual
#   pixels when you first draw it. Virtual Proxy = lazy loading behind the
#   same interface.
#
# SETUP:
#   crystal run 061_proxy_virtual_image.cr
# =============================================================================

# Module `Image`.
module Image
  # Return a short String describing the drawn shape/node.
  abstract def draw : String
end

# Expensive real subject.
class RealImage
  getter filename : String
  def initialize(@filename : String)
    load_from_disk  # simulate expense in constructor
  end
  private def load_from_disk : Nil
    sleep 0.2
  end
  # Return a short String describing the drawn shape/node.
  def draw : String; "drawing #{@filename}"; end
end

# Virtual proxy: defers construction until first use.
class ImageProxy
  include Image
  def initialize(@filename : String); end
  @real : RealImage?

  # Return a short String describing the drawn shape/node.
  def draw : String
    # Lazy initialization.
    real = (@real ||= RealImage.new(@filename))
    real.draw
  end

  # Expose whether the real image has been loaded — useful for tests.
  def loaded? : Bool
    !@real.nil?
  end
end

# ---- Demonstration ----------------------------------------------------------
img = ImageProxy.new("huge.png")
puts "loaded? #{img.loaded?}"  # false
puts img.draw                   # loads here
puts "loaded? #{img.loaded?}"  # true
puts img.draw                   # reuses; fast

# =============================================================================
# EXERCISE 1
#   Add a `preload` method to warm the cache explicitly.
# SOLUTION 1:
#   def preload : Nil
#     @real ||= RealImage.new(@filename)
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Make the proxy thread-safe for concurrent `draw` calls.
# SOLUTION 2:
#   @lock = Mutex.new
#   def draw : String
#     @lock.synchronize { @real ||= RealImage.new(@filename) }
#     @real.as(RealImage).draw
#   end
#   # (Or use a "double-checked" pattern; Crystal's Mutex#synchronize is
#   # cheap enough that a single lock is usually fine.)
# =============================================================================

# =============================================================================
# EXERCISE 3
#   How does this differ from a Decorator with caching?
# SOLUTION 3:
#   Decorator's job is to add behavior — cache is one example, but the
#   decorator's subject (interface) could be any Image. Proxy's job is to
#   stand in for the exact same subject and control access to it. A
#   proxy typically owns construction/timing; a decorator typically wraps
#   an already-existing subject and adds orthogonal behavior.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
