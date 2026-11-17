# 006_xlsx.cr
# ---------------------------------------------------------------------------
# Format: XLSX (Excel .xlsx - a zip of XML parts; needs a shard to read/write)
# ---------------------------------------------------------------------------
# ELI5:
#   An .xlsx file isn't plain text - it's a ZIP archive containing several XML
#   files (one per worksheet, plus shared strings, styles, etc.). You can't
#   sensibly hand-build it. The `xlsx` shard wraps all that: you create a
#   workbook, add worksheets, set cells by (row, column), and call save.
#
# Best approach (per the table): the `xlsx` shard for read/write.
#   (deps.yml: xlsx github: nicolabernardy/xlsx)
#
#   Because the shard needs to be installed via `shards install` before this
#   file can compile, the demo is wrapped so it tells you exactly what to do if
#   the shard isn't present. The CODE shows the idiomatic xlsx-shard usage.
#
# Run:  (1) put the deps in shard.yml, (2) `shards install`, (3) `crystal 006_xlsx.cr`
# ---------------------------------------------------------------------------

# When the shard is installed (see README), uncomment the require below:
# require "xlsx"

# A thin wrapper around the xlsx shard's Workbook API. We isolate the shard
# calls here so the rest of the file reads clearly even before `shards install`.
module XlsxExample
  # Build a workbook with one sheet of sales data, then return the path written.
  def self.build_sales_report(path : String) : String
    # --- shard API usage (idiomatic) ---------------------------------------
    # workbook = Xlsx::Workbook.new
    # sheet = workbook.add_sheet("Sales")
    # sheet[0, 0] = "Product"      # (row, col) - 0-indexed
    # sheet[0, 1] = "Units"
    # sheet[0, 2] = "Revenue"
    # data = [
    #   {"Widget", 150, 1500.50},
    #   {"Gadget", 89, 890.25},
    #   {"Gizmo",  220, 3300.00},
    # ]
    # data.each_with_index do |row, i|
    #   sheet[i + 1, 0] = row[0].as(String)
    #   sheet[i + 1, 1] = row[1].as(Int32)
    #   sheet[i + 1, 2] = row[2].as(Float64)
    # end
    # workbook.save(path)

    # FALLBACK when the shard isn't installed: write a CSV instead, so the demo
    # still produces output. We print a clear notice.
    puts "  (xlsx shard not installed - writing CSV fallback at #{path}.csv)"
    csv_path = "#{path}.csv"
    File.write(csv_path, "Product,Units,Revenue\nWidget,150,1500.50\nGadget,89,890.25\nGizmo,220,3300.00\n")
    csv_path
  end

  # Read a workbook back. With the shard:
  #   workbook = Xlsx::Workbook.open(path)
  #   sheet = workbook[0]
  #   sheet.rows.each { |row| puts row.map(&.value) }
  def self.read(path : String) : Array(Array(String))
    # Fallback: read the CSV the fallback wrote.
    csv_path = path.ends_with?(".csv") ? path : "#{path}.csv"
    return [[]] unless File.exists?(csv_path)
    CSV.parse(File.read(csv_path))
  end
end

require "csv"   # only for the fallback path; safe to require unconditionally

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== XLSX (xlsx shard) ==="
puts "  To enable real .xlsx output: add `xlsx` to shard.yml and run `shards install`."
puts "  (see README for the exact dependency line)"
puts ""

dest = "/tmp/crystal_xlsx_006.xlsx"
written = XlsxExample.build_sales_report(dest)
puts "  wrote: #{written}"

puts "\n=== read it back ==="
rows = XlsxExample.read(dest)
rows.each { |r| puts "  #{r.inspect}" }

# Compute the total revenue from the data we wrote.
data_rows = rows[1..]? || []
total = data_rows.sum { |r| r[2]?.try(&.to_f) || 0.0 }
puts "\n  total revenue: $#{total} (expect 5690.75)"

# Cleanup the fallback CSV if it exists.
["#{dest}.csv", dest].each { |p| File.delete(p) if File.exists?(p) }

# ---------------------------------------------------------------------------
# EXERCISES (each is a top-level method - call them below)
# ---------------------------------------------------------------------------

# --- Exercise 1: build a workbook with 2 sheets -----------------------------
def exercise_1
  # With the shard:
  #   wb = Xlsx::Workbook.new
  #   wb.add_sheet("Sheet1"); wb.add_sheet("Sheet2")
  #   wb.save("/tmp/ex1.xlsx")
  # Fallback: write 2 CSVs.
  ["ex1_s1", "ex1_s2"].each_with_index do |name, i|
    File.write("/tmp/crystal_#{name}_#{Process.pid}.csv", "col\nval#{i}\n")
  end
  puts "Exercise 1 -> built a 2-sheet workbook (fallback: 2 CSVs)"
  Dir["/tmp/crystal_ex1_*_#{Process.pid}.csv"].each { |p| File.delete(p) }
end

# --- Exercise 2: read a specific cell (row 1, col 0) -----------------------
def exercise_2
  path = "/tmp/crystal_ex2_#{Process.pid}.csv"
  File.write(path, "name,age\nAlice,30\n")
  rows = CSV.parse(File.read(path))
  cell = rows[1][0]
  File.delete(path)
  puts "Exercise 2 -> cell (1,0) = #{cell} (expect Alice)"
end

# --- Exercise 3: write a numeric column and compute its sum -----------------
def exercise_3
  path = "/tmp/crystal_ex3_#{Process.pid}.csv"
  File.write(path, "n\n1\n2\n3\n4\n5\n")
  rows = CSV.parse(File.read(path))
  sum = rows[1..].sum { |r| r[0].to_i }
  File.delete(path)
  puts "Exercise 3 -> sum of column = #{sum} (expect 15)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
