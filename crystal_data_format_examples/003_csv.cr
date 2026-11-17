# 003_csv.cr
# ---------------------------------------------------------------------------
# Format: CSV (stdlib CSV.parse + CSV.build)
# ---------------------------------------------------------------------------
# ELI5:
#   CSV = Comma-Separated Values. Each row is a line; fields are split by commas.
#   No nesting, no types - just rows and columns. It's the lingua franca of
#   spreadsheets and data exports because it's dead simple and every tool reads
#   it. Crystal's stdlib parses CSV into arrays-of-arrays (or rows) and builds
#   it back out with proper quoting.
#
# Best approach (per the table): `CSV.parse`, `CSV.build` (stdlib).
#
# Run:  crystal 003_csv.cr       (Crystal 1.x, stdlib only)
# ---------------------------------------------------------------------------

require "csv"

# --- 1. Parse a CSV string ---------------------------------------------------
csv = <<-CSV
  name,age,city
  Alice,30,NYC
  Bob,25,LA
  Carol,40,SF
CSV

rows = CSV.parse(csv)
puts "=== CSV.parse ==="
rows.each_with_index do |row, i|
  puts "  row #{i}: #{row}"
end

# --- 2. Parse with a header row (each row becomes a Hash) -------------------
puts "\n=== CSV with headers (Hash per row) ==="
headers = rows[0]
rows[1..].each do |row|
  record = headers.zip(row).to_h
  puts "  #{record}"
end

# --- 3. Build CSV programmatically -----------------------------------------
puts "\n=== CSV.build (handles quoting) ==="
built = CSV.build do |csv|
  csv.row "name", "notes"
  csv.row "Alice", "likes \"quotes\""
  csv.row "Bob", "has, comma"
  csv.row "Carol", "newline\nin field"
end
puts built

# --- 4. Parse the built CSV back (verify round-trip preserves fields) -----
puts "\n=== round-trip parse ==="
reparsed = CSV.parse(built)
reparsed.each { |r| puts "  #{r.inspect}" }

# --- 5. Streaming: process a large CSV row-by-row without loading all in RAM --
puts "\n=== CSV.each_row (streaming, lazy) ==="
CSV.each_row(csv) do |row|
  puts "  streamed: #{row[0]} (#{row[1]} yo, #{row[2]})"
end

# --- 6. Read/write a CSV file ----------------------------------------------
path = "/tmp/crystal_csv_003.csv"
File.open(path, "w") do |f|
  CSV.build(f) do |csv|
    csv.row "x", "y"
    csv.row 1, 2
    csv.row 3, 4
  end
end
puts "\n=== CSV file at #{path} ==="
puts File.read(path)
File.delete(path)

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: parse and compute the average of a numeric column ----------
def exercise_1
  require "csv"
  csv = "n\n10\n20\n30\n"
  rows = CSV.parse(csv)
  nums = rows[1..].map { |r| r[0].to_i }
  avg = nums.sum.to_f / nums.size
  puts "Exercise 1 -> average of [10,20,30] = #{avg} (expect 20.0)"
end

# --- Exercise 2: build CSV then re-parse and confirm row count -------------
def exercise_2
  require "csv"
  built = CSV.build { |c| c.row "a"; c.row "b"; c.row "c" }
  count = CSV.parse(built).size
  puts "Exercise 2 -> built CSV has #{count} rows (expect 3)"
end

# --- Exercise 3: handle a field containing a comma (quoting) ----------------
def exercise_3
  require "csv"
  built = CSV.build { |c| c.row "Smith, John", "30" }
  parsed = CSV.parse(built)
  puts "Exercise 3 -> field with comma preserved? #{parsed[0][0] == "Smith, John"} (#{parsed[0][0].inspect})"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
