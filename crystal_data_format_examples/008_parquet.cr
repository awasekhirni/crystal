# 008_parquet.cr
# ---------------------------------------------------------------------------
# Format: Parquet (columnar storage; read/write via the DuckDB CLI external tool)
# ---------------------------------------------------------------------------
# ELI5:
#   Parquet is a *columnar* binary format - instead of storing rows one after
#   another, it stores each COLUMN contiguously. That's a win for analytics
#   ("average price across 1B rows" only touches one column, not the whole
#   table). Parquet is complex internally (compression, encodings, metadata),
#   so we don't hand-build it - we shell out to the DuckDB CLI, which can CREATE
#   a Parquet file from SQL and SELECT from one as if it were a table.
#
# Best approach (per the table): external tool (DuckDB) via Process.run.
#   No DuckDB binding for Crystal is used here; we invoke the CLI subprocess.
#
# Run:  crystal 008_parquet.cr    (needs the `duckdb` CLI on PATH;
#       degrades to a CSV-backed demo if DuckDB isn't installed)
# ---------------------------------------------------------------------------

require "json"
require "csv"

# A small wrapper around the DuckDB CLI: run a SQL statement, return its output.
module DuckDb
  # Returns {:ok, stdout} if duckdb ran, {:missing, nil} if it's not installed.
  def self.run(sql : String) : {Bool, String}
    unless command_available?("duckdb")
      return {false, "(duckdb CLI not installed)"}
    end
    # `duckdb -c "<sql>"` runs one statement against an in-memory DB.
    output = IO::Memory.new
    status = Process.run("duckdb", ["-c", sql], output: output, error: output)
    {status.success?, output.to_s}
  end

  def self.command_available?(cmd) : Bool
    !`which #{cmd} 2>/dev/null`.strip.empty?
  rescue
    false
  end
end

# A fallback Parquet-like demo (used when DuckDB isn't installed): we still
# show the columnar shape by reading a CSV column-at-a-time into memory.
module ParquetFallback
  # Pretend we have a Parquet file: write CSV, then expose columnar reads.
  def self.write_rows(path : String, rows : Array(Array(String)))
    File.open(path, "w") do |f|
      rows.each { |r| f.puts r.join(",") }
    end
  end

  # Read a single column by index (the Parquet advantage: only touch one column).
  def self.read_column(path : String, col_index : Int32) : Array(String)
    File.each_line(path).map { |l| l.split(",")[col_index]? || "" }.to_a
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== Parquet via DuckDB ==="

parquet_path = "/tmp/crystal_parquet_008.parquet"

# 1. Try the real DuckDB path: write a Parquet file from a SQL query.
ok, out = DuckDb.run(%(
  COPY (SELECT 'Alice' AS name, 30 AS age UNION ALL SELECT 'Bob', 25)
  TO '#{parquet_path}' (FORMAT PARQUET);
))

if ok
  puts "  wrote Parquet via DuckDB: #{parquet_path}"
  puts "  duckdb output: #{out.strip}"

  # 2. Read it back with a SELECT against the Parquet file.
  ok2, out2 = DuckDb.run(%(SELECT * FROM read_parquet('#{parquet_path}');))
  puts "\n  read back via DuckDB:"
  puts out2
  File.delete(parquet_path) if File.exists?(parquet_path)
else
  puts "  #{out}"
  puts "  Falling back to a CSV-backed columnar demo:"

  # Fallback: write a CSV and demonstrate columnar reads (the Parquet shape).
  csv_path = "/tmp/crystal_parquet_008_fallback.csv"
  ParquetFallback.write_rows(csv_path, [
    ["name", "age"],
    ["Alice", "30"],
    ["Bob", "25"],
  ])
  puts "  wrote CSV fallback at #{csv_path}"

  puts "\n  columnar read (only the 'age' column):"
  ages = ParquetFallback.read_column(csv_path, 1)
  puts "    #{ages.inspect} (header + 2 values)"
  puts "  avg age = #{ages[1..].map(&.to_i).sum.to_f / 2}"

  File.delete(csv_path)
end

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: check whether duckdb is installed --------------------------
def exercise_1
  available = DuckDb.run("SELECT 1;")
  puts "Exercise 1 -> duckdb available? #{available[0]}"
end

# --- Exercise 2: run a COUNT(*) against a Parquet file (if present) ----------
def exercise_2
  ok, out = DuckDb.run("SELECT COUNT(*) FROM read_parquet('/tmp/crystal_parquet_008.parquet');")
  if ok
    puts "Exercise 2 -> row count: #{out.strip}"
  else
    puts "Exercise 2 -> (#{out.strip} - skipped)"
  end
end

# --- Exercise 3: columnar read from the fallback CSV -------------------------
def exercise_3
  path = "/tmp/crystal_ex3_#{Process.pid}.csv"
  ParquetFallback.write_rows(path, [["a", "b"], ["1", "10"], ["2", "20"], ["3", "30"]])
  col = ParquetFallback.read_column(path, 1)
  sum = col[1..].map(&.to_i).sum
  File.delete(path)
  puts "Exercise 3 -> column b values: #{col[1..].inspect}, sum = #{sum} (expect 60)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
