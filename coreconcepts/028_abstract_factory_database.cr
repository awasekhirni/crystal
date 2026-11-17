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
#   You're building a data layer that should run on Postgres or SQLite.
#   Each engine has its own connection, its own query, its own transaction.
#   Abstract Factory = pick a "Postgres factory" or a "SQLite factory" once,
#   and every piece it hands you is guaranteed compatible.
#
# SETUP:
#   crystal run 028_abstract_factory_database.cr
# =============================================================================

# --- Abstract products -------------------------------------------------------
module Connection
  # Return the result of `open`.
  abstract def open : String
  # Release any resources held by this importer.  No-op by default.
  abstract def close : String
end

# Module `Query`.
module Query
  # Return the result of `execute`.
  abstract def execute(sql : String) : String
end

# Module `Transaction`.
module Transaction
  # Return the result of `begin_tx`.
  abstract def begin_tx : String
  # Return the result of `commit`.
  abstract def commit : String
end

# --- Postgres family ---------------------------------------------------------
class PgConnection
  include Connection
  # Return the result of `open`.
  def open : String; "PG: opened TCP"; end
  # Release any resources held by this importer.  No-op by default.
  def close : String; "PG: closed"; end
end
# Concrete class `PgQuery`.
class PgQuery
  include Query
  # Return the result of `execute`.
  def execute(sql : String) : String; "PG exec: #{sql}"; end
end
# Concrete class `PgTransaction`.
class PgTransaction
  include Transaction
  # Return the result of `begin_tx`.
  def begin_tx : String; "PG BEGIN"; end
  # Return the result of `commit`.
  def commit : String; "PG COMMIT"; end
end

# --- SQLite family -----------------------------------------------------------
class SqliteConnection
  include Connection
  # Return the result of `open`.
  def open : String; "SQLite: opened file"; end
  # Release any resources held by this importer.  No-op by default.
  def close : String; "SQLite: closed"; end
end
# Concrete class `SqliteQuery`.
class SqliteQuery
  include Query
  # Return the result of `execute`.
  def execute(sql : String) : String; "SQLite exec: #{sql}"; end
end
# Concrete class `SqliteTransaction`.
class SqliteTransaction
  include Transaction
  # Return the result of `begin_tx`.
  def begin_tx : String; "SQLite BEGIN"; end
  # Return the result of `commit`.
  def commit : String; "SQLite COMMIT"; end
end

# --- Abstract factory --------------------------------------------------------
abstract class DBFactory
  # Return the result of `connection`.
  abstract def connection : Connection
  # Return the result of `query`.
  abstract def query : Query
  # Return the result of `transaction`.
  abstract def transaction : Transaction
end

# Concrete class `PgFactory` -- extends DBFactory.
class PgFactory < DBFactory
  # Return the result of `connection`.
  def connection : Connection; PgConnection.new; end
  # Return the result of `query`.
  def query : Query; PgQuery.new; end
  # Return the result of `transaction`.
  def transaction : Transaction; PgTransaction.new; end
end

# Concrete class `SqliteFactory` -- extends DBFactory.
class SqliteFactory < DBFactory
  # Return the result of `connection`.
  def connection : Connection; SqliteConnection.new; end
  # Return the result of `query`.
  def query : Query; SqliteQuery.new; end
  # Return the result of `transaction`.
  def transaction : Transaction; SqliteTransaction.new; end
end

# --- Client: knows only the abstract factory --------------------------------
def run_migration(factory : DBFactory, sql : String) : Nil
  conn = factory.connection
  puts conn.open
  tx = factory.transaction
  puts tx.begin_tx
  puts factory.query.execute(sql)
  puts tx.commit
  puts conn.close
end

# ---- Demonstration ----------------------------------------------------------
run_migration(PgFactory.new, "CREATE TABLE users(id INT)")
puts "---"
run_migration(SqliteFactory.new, "CREATE TABLE users(id INTEGER)")

# =============================================================================
# EXERCISE 1
#   Add a MySqlFactory family with all three products.
# SOLUTION 1:
#   (Repeat the PG trio with MySQL-specific strings.) Then instantiate
#   MySqlFactory in run_migration — client code doesn't change.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add an in-memory "TestFactory" that records queries to a buffer for
#   assertions.
# SOLUTION 2:
#   class RecordingQuery
#     include Query
#     getter executed = [] of String
#     def execute(sql : String) : String; @executed << sql; "ok"; end
#   end
#   # TestFactory holds the RecordingQuery instance so callers can inspect
#   # it after run_migration.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Justify why Abstract Factory is preferable to `if engine == :pg` sprinkled
#   throughout the data layer.
# SOLUTION 3:
#   Scattered conditionals duplicate the "family choice" at every call site,
#   invite accidental mixing, and require edits for each new engine. The
#   Abstract Factory confines the engine decision to a single place (which
#   factory is instantiated) and the type system prevents cross-family use.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
