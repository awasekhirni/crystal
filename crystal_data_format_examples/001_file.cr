# 001_file.cr
# ---------------------------------------------------------------------------
# Format: File (the File class - the universal "raw bytes on disk" format)
# ---------------------------------------------------------------------------
# ELI5:
#   Before any fancy format, there's just "a file" - a named blob of bytes on
#   disk. The File class is Crystal's gateway to reading, writing, appending,
#   and asking the OS about files. Every other format in this collection
#   ultimately becomes bytes that File hands to the OS.
#
# Best approach (per the table): the `File` class (stdlib).
#
# Run:  crystal 001_file.cr       (Crystal 1.x, stdlib only)
# ---------------------------------------------------------------------------

# --- 1. Write a text file (whole string at once) -----------------------------
path = "/tmp/crystal_file_demo_001.txt"
File.write(path, "hello, file!\nline two\n")

# --- 2. Read it back (whole file as a string) --------------------------------
contents = File.read(path)
puts "=== File.read ==="
puts contents

# --- 3. Read line by line (lazy iterator, doesn't load whole file) ----------
puts "=== File.each_line (lazy) ==="
File.each_line(path) do |line|
  puts "  line: #{line.inspect}"
end

# --- 4. Append (mode "a") ---------------------------------------------------
File.open(path, "a") { |f| f.puts "appended line" }
puts "=== after append ==="
puts File.read(path)

# --- 5. Binary read/write (Bytes, not String) -------------------------------
bin_path = "/tmp/crystal_file_demo_001.bin"
bytes = Bytes[0x48, 0x49, 0x00, 0xFF, 0x01]   # "HI" + null + 0xFF + 1
File.write(bin_path, bytes)
read_bytes = File.read(bin_path)    # returns String, but bytes are preserved
puts "=== binary round-trip ==="
puts "  wrote: #{bytes.inspect}"
puts "  read : #{read_bytes.bytes.inspect} (length=#{read_bytes.bytesize})"

# --- 6. File info: size, exists?, mtime, type --------------------------------
puts "=== File.info ==="
info = File.info(path)
puts "  exists?    #{File.exists?(path)}"
puts "  size       #{info.size} bytes"
puts "  mtime      #{info.modification_time}"
puts "  type       #{info.type}"   # :file, :directory, :symlink

# --- 7. Safe open with auto-close (block form) ------------------------------
puts "=== File.open with block (auto-closed) ==="
total = 0
File.open(path, "r") do |f|
  # f is an IO::File; we read the whole buffer.
  total = f.gets_to_end.size
end
puts "  read #{total} bytes via block IO"

# --- 8. Dir listing (related: find files in a directory) --------------------
puts "=== Dir entries in /tmp (first 5) ==="
Dir["/tmp/crystal_file_demo_001.*"].each { |p| puts "  #{p}" }

# Cleanup
File.delete(path)
File.delete(bin_path)

# ---------------------------------------------------------------------------
# EXERCISES (each is a top-level method - call them below)
# ---------------------------------------------------------------------------

# --- Exercise 1: count words in a file --------------------------------------
def exercise_1
  path = "/tmp/crystal_ex1_#{Process.pid}.txt"
  File.write(path, "the quick brown fox jumps over the lazy dog")
  count = File.read(path).split.size
  File.delete(path)
  puts "Exercise 1 -> word count: #{count} (expect 9)"
end

# --- Exercise 2: copy a file by reading/writing bytes -----------------------
def exercise_2
  src = "/tmp/crystal_ex2_src_#{Process.pid}.txt"
  dst = "/tmp/crystal_ex2_dst_#{Process.pid}.txt"
  File.write(src, "copy me\n")
  data = File.read(src)
  File.write(dst, data)
  same = File.read(src) == File.read(dst)
  File.delete(src); File.delete(dst)
  puts "Exercise 2 -> files identical after copy? #{same}"
end

# --- Exercise 3: append-only log writer that never overwrites ---------------
def exercise_3
  path = "/tmp/crystal_ex3_#{Process.pid}.log"
  3.times { |i| File.open(path, "a") { |f| f.puts "log entry #{i}" } }
  lines = File.read(path).lines
  File.delete(path)
  puts "Exercise 3 -> log has #{lines.size} entries (expect 3): #{lines.inspect}"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
