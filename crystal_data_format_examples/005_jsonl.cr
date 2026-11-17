# 005_jsonl.cr
# ---------------------------------------------------------------------------
# Format: JSONL (JSON Lines - one JSON object per line, no surrounding array)
# ---------------------------------------------------------------------------
# ELI5:
#   Regular JSON wraps a list in [...]. JSONL is just "one JSON object per
#   line" - no outer brackets, no commas between. Why? Because you can stream
#   it: append a new record by writing one line, never re-read the whole file.
#   It's the format of choice for logs, event streams, and big-data pipelines.
#
#   The table marks Crystal stdlib support as "⚠️ Manual" - there's no built-in
#   JSONL module, but it's trivial: one `to_json` per line on write, one
#   `JSON.parse` (or `from_json`) per line on read.
#
# Best approach (per the table): one `to_json` per line (manual, stdlib).
#
# Run:  crystal 005_jsonl.cr       (Crystal 1.x, stdlib only)
# ---------------------------------------------------------------------------

require "json"

# --- 1. Build a serializable record type -----------------------------------
class LogEntry
  include JSON::Serializable
  property ts : String
  property level : String
  property msg : String
  def initialize(@ts, @level, @msg); end
end

# --- 2. Write JSONL: one to_json per line -----------------------------------
puts "=== building JSONL (one to_json per line) ==="
records = [
  LogEntry.new("2026-01-01T00:00:01Z", "INFO", "server started"),
  LogEntry.new("2026-01-01T00:00:05Z", "INFO", "accepted connection"),
  LogEntry.new("2026-01-01T00:00:10Z", "WARN", "slow query"),
  LogEntry.new("2026-01-01T00:00:15Z", "ERROR", "disk full"),
]
jsonl = records.map(&.to_json).join("\n")
puts jsonl

# --- 3. Write JSONL to a file (append-safe: each line is independent) -------
path = "/tmp/crystal_jsonl_005.jsonl"
File.open(path, "w") do |f|
  records.each do |r|
    f.puts r.to_json     # one JSON object per line
  end
end
puts "\n=== written to #{path} ==="

# --- 4. Read JSONL back: parse each line independently ----------------------
puts "\n=== parsing JSONL (one line at a time) ==="
File.each_line(path) do |line|
  next if line.strip.empty?
  entry = LogEntry.from_json(line)
  puts "  [#{entry.level}] #{entry.ts} - #{entry.msg}"
end

# --- 5. Stream-accumulate: count WARN+ERROR entries ------------------------
puts "\n=== streaming filter: count WARN/ERROR ==="
warning_count = 0
File.each_line(path) do |line|
  next if line.strip.empty?
  entry = LogEntry.from_json(line)
  case entry.level
  when "WARN", "ERROR"
    warning_count += 1
  end
end
puts "  found #{warning_count} concerning entries"

# --- 6. Append a new record (the key JSONL advantage: no rewrite needed) ---
puts "\n=== append one record (no rewrite) ==="
File.open(path, "a") { |f| f.puts LogEntry.new("2026-01-01T00:00:20Z", "INFO", "recovered").to_json }
total_lines = File.read(path).lines.size
puts "  file now has #{total_lines} lines"

File.delete(path)

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: write 3 records, read them back, verify count --------------
class Event
  include JSON::Serializable
  property id : Int32
  property name : String
  def initialize(@id, @name); end
end

def exercise_1
  events = [Event.new(1, "a"), Event.new(2, "b"), Event.new(3, "c")]
  jsonl = events.map(&.to_json).join("\n")
  parsed = jsonl.lines.map { |l| Event.from_json(l) }
  puts "Exercise 1 -> wrote #{events.size}, read #{parsed.size} (match: #{events.size == parsed.size})"
end

# --- Exercise 2: append-only log, then read all and confirm order ----------
def exercise_2
  path = "/tmp/crystal_jsonl_ex2_#{Process.pid}.jsonl"
  3.times { |i| File.open(path, "a") { |f| f.puts Event.new(i, "ev#{i}").to_json } }
  ids = File.each_line(path).map { |l| Event.from_json(l).id }.to_a
  File.delete(path)
  puts "Exercise 2 -> append order preserved: #{ids == [0, 1, 2]}"
end

# --- Exercise 3: filter JSONL for records where id is even -----------------
def exercise_3
  jsonl = [Event.new(1, "odd"), Event.new(2, "even"), Event.new(3, "odd"), Event.new(4, "even")].map(&.to_json).join("\n")
  evens = jsonl.lines.map { |l| Event.from_json(l) }.select(&.id.even?)
  puts "Exercise 3 -> even-id records: #{evens.map(&.id)} (expect [2, 4])"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
