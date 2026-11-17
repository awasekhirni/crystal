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
#   A web API returns results one page at a time. Iterator hides paging: from
#   the caller's view, you just "keep calling next" until the data runs out.
#   Perfect for streaming 10 million rows without loading them all.
#
# SETUP:
#   crystal run 074_iterator_paged_api.cr
# =============================================================================

# --- Simulated API ---------------------------------------------------------
class FakePagedApi
  def initialize(@data : Array(String), @page_size : Int32 = 3); end

  # Returns a page of results and the next cursor; nil means end.
  def fetch(cursor : Int32) : Tuple(Array(String), Int32?)
    page = @data[cursor, @page_size]? || [] of String
    next_cursor = cursor + page.size < @data.size ? cursor + page.size : nil
    {page, next_cursor}
  end
end

# --- Lazy paged iterator ---------------------------------------------------
class PagedIterator
  include Iterator(String)

  def initialize(@api : FakePagedApi, @cursor : Int32 = 0)
    @buffer = [] of String
    @done = false
  end

  # Return the result of `next`.
  def next : Iterator::Stop | String
    while @buffer.empty? && !@done
      page, next_cursor = @api.fetch(@cursor)
      @buffer.concat(page)
      @done = true if next_cursor.nil?
      @cursor = next_cursor || @cursor
    end
    return stop if @buffer.empty?
    @buffer.shift
  end
end

# ---- Demonstration ----------------------------------------------------------
api = FakePagedApi.new((1..10).map(&.to_s))
iter = PagedIterator.new(api)

# Lazily take 5 items — never fetches beyond what's needed.
first_five = iter.first(5)
puts first_five

# Or consume all:
puts PagedIterator.new(api).to_a

# =============================================================================
# EXERCISE 1
#   Add retry on API failure (simulate by raising every N calls).
# SOLUTION 1:
#   Wrap fetch in a begin/rescue with a small retry loop. Since the iterator
#   is stateful, only retry the current fetch — no cursor advance on error.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Expose `each_page { |page| ... }` for callers who want the batching
#   visible.
# SOLUTION 2:
#   def each_page(&)
#     cursor = 0
#     loop do
#       page, next_cursor = @api.fetch(cursor)
#       yield page
#       break unless next_cursor
#       cursor = next_cursor
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Compare with loading everything into an Array first.
# SOLUTION 3:
#   Array: O(n) memory, one big latency spike, simple. Iterator: O(page)
#   memory, streams with constant latency per page, early termination
#   supported. Prefer iterator for large datasets and UIs that can start
#   displaying before everything is loaded.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
