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
#   Writing SQL is like ordering a pizza: "select these, from that table,
#   where this, ordered by that". Builder turns that flow into method calls
#   that assemble safe, readable SQL.
#
# SETUP:
#   crystal run 032_builder_sql_query.cr
# =============================================================================

# Concrete class `SqlQuery`.
class SqlQuery
  getter sql : String
  def initialize(@sql : String); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << @sql; end
end

# Concrete class `SelectBuilder`.
class SelectBuilder
  @columns = [] of String
  @from : String?
  @wheres = [] of String
  @order : String?
  @limit : Int32?

  # Accept one or more column names (splat) so callers can write
  # `.select("id", "name", "email")` fluently.
  def select(*cols : String) : self
    @columns.concat(cols)
    self
  end

  # Return the result of `from`.
  def from(table : String) : self
    @from = table
    self
  end

  # Return the result of `where`.
  def where(clause : String) : self
    @wheres << clause
    self
  end

  # Return the result of `order_by`.
  def order_by(clause : String) : self
    @order = clause
    self
  end

  # Return the result of `limit`.
  def limit(n : Int32) : self
    @limit = n
    self
  end

  # Build and return the constructed product.
  def build : SqlQuery
    raise "no columns" if @columns.empty?
    raise "no FROM table" unless @from
    sql = String.build do |io|
      io << "SELECT " << @columns.join(", ")
      io << " FROM " << @from.not_nil!
      io << " WHERE " << @wheres.join(" AND ") unless @wheres.empty?
      io << " ORDER BY " << @order.not_nil! if @order
      io << " LIMIT " << @limit.not_nil! if @limit
    end
    SqlQuery.new(sql)
  end
end

# ---- Demonstration ----------------------------------------------------------
q = SelectBuilder.new
  .select("id", "name", "email")
  .from("users")
  .where("active = true")
  .where("age >= 18")
  .order_by("name ASC")
  .limit(50)
  .build
puts q

# =============================================================================
# EXERCISE 1
#   Add `join(table, on)` support.
# SOLUTION 1:
#   @joins = [] of String
#   def join(table : String, on : String) : self
#     @joins << "JOIN #{table} ON #{on}"; self
#   end
#   # In build, io << " " << @joins.join(" ") after FROM.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add parameterized values via `where_param(col, value)` that captures
#   values in an array (avoiding SQL injection).
# SOLUTION 2:
#   @params = [] of DB::Any   # or String in this toy
#   def where_param(col : String, value : String) : self
#     @wheres << "#{col} = $#{@params.size + 1}"
#     @params << value
#     self
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why is builder a natural home for validation of required fields?
# SOLUTION 3:
#   build is the single point where state becomes a product. Validating
#   there avoids repeating checks in each setter and guarantees no invalid
#   SqlQuery object is ever constructed — the class stays invariant-safe.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
