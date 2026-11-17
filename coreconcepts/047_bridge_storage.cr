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
#   Your "file" abstraction should be the same whether the bytes live on
#   local disk, in S3, or in memory. Bridge: a File abstraction contains a
#   Storage backend; you swap backends without changing File's interface.
#
# SETUP:
#   crystal run 047_bridge_storage.cr
# =============================================================================

# --- Implementor: Storage -------------------------------------------------
module Storage
  # Store `data` under `key`.  Returns Nil.
  abstract def put(key : String, data : String) : Nil
  # Look up `key`; returns the value or Nil if absent.
  abstract def get(key : String) : String?
end

# Concrete class `MemoryStorage`.
class MemoryStorage
  include Storage
  @data = {} of String => String
  # Store `data` under `key`.  Returns Nil.
  def put(key, data) : Nil; @data[key] = data; end
  # Look up `key`; returns the value or Nil if absent.
  def get(key) : String?; @data[key]?; end
end

# Concrete class `DiskStorage`.
class DiskStorage
  include Storage
  def initialize(@root : String = "/tmp/bridge_store"); end
  # Store `data` under `key`.  Returns Nil.
  def put(key, data) : Nil
    Dir.mkdir_p(@root)
    File.write(File.join(@root, key), data)
  end
  # Look up `key`; returns the value or Nil if absent.
  def get(key) : String?
    path = File.join(@root, key)
    File.exists?(path) ? File.read(path) : nil
  end
end

# --- Abstraction: DocumentStore -------------------------------------------
class DocumentStore
  def initialize(@storage : Storage); end

  # Persist the rows.  Returns Nil.
  def save(id : String, content : String) : Nil
    @storage.put("docs/#{id}.txt", content)
  end

  # Return the result of `load`.
  def load(id : String) : String?
    @storage.get("docs/#{id}.txt")
  end

  # Hot-swap the backend (Bridge lets us).
  def storage=(@storage : Storage); end
end

# ---- Demonstration ----------------------------------------------------------
mem = MemoryStorage.new
store = DocumentStore.new(mem)
store.save("1", "hello")
puts store.load("1")

store.storage = DiskStorage.new("/tmp/bridge_047")
store.save("2", "to disk")
puts store.load("2")

# =============================================================================
# EXERCISE 1
#   Add an EncryptedStorage that wraps another Storage (Bridge + Decorator).
# SOLUTION 1:
#   class EncryptedStorage
#     include Storage
#     def initialize(@inner : Storage); end
#     def put(k, d); @inner.put(k, d.reverse); end
#     def get(k)
#       v = @inner.get(k)
#       v.try(&.reverse)
#     end
#   end
#   store.storage = EncryptedStorage.new(MemoryStorage.new)
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "S3Storage" skeleton with a fake network latency.
# SOLUTION 2:
#   class S3Storage
#     include Storage
#     def put(k, d); sleep 0.01; puts "S3 PUT #{k}"; end
#     def get(k); sleep 0.01; "s3 content for #{k}"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is `storage=` helpful at runtime, and when might it bite?
# SOLUTION 3:
#   Useful for failover (S3 down → fallback memory) and environment tests.
#   Dangerous if the swap happens concurrently with a multi-step operation
#   (e.g., read-modify-write split across backends): the operation may hit
#   two incompatible stores. Solve by scoping operations or by making swaps
#   atomic relative to operation boundaries.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
