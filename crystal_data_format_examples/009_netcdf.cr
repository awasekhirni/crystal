# 009_netcdf.cr
# ---------------------------------------------------------------------------
# Format: NetCDF (Network Common Data Form - scientific arrays; via ncdump)
# ---------------------------------------------------------------------------
# ELI5:
#   NetCDF stores multi-dimensional SCIENTIFIC arrays: a 3D grid of temperature
#   readings over (latitude, longitude, time), each tagged with units and a
#   timestamp. Used heavily in climate/weather/ocean models. The binary format
#   is intricate; the standard external tool is `ncdump` (text view of a .nc
#   file's header + data) and `ncks` for slicing. We shell out to ncdump.
#
# Best approach (per the table): external tool (ncdump / Python netCDF4).
#   No native Crystal binding; we invoke ncdump via Process.run.
#
# Run:  crystal 009_netcdf.cr    (needs `ncdump` on PATH;
#       degrades to an embedded sample header if ncdump isn't installed)
# ---------------------------------------------------------------------------

# Wrap the ncdump CLI: given a .nc file, return its header text.
module NcDump
  def self.header(nc_path : String) : {Bool, String}
    unless command_available?("ncdump")
      return {false, "(ncdump not installed)"}
    end
    out = IO::Memory.new
    status = Process.run("ncdump", ["-h", nc_path], output: out, error: out)
    {status.success?, out.to_s}
  end

  # Full data dump (not just header).
  def self.full(nc_path : String) : {Bool, String}
    unless command_available?("ncdump")
      return {false, "(ncdump not installed)"}
    end
    out = IO::Memory.new
    status = Process.run("ncdump", [nc_path], output: out, error: out)
    {status.success?, out.to_s}
  end

  def self.command_available?(cmd) : Bool
    !`which #{cmd} 2>/dev/null`.strip.empty?
  rescue
    false
  end
end

# A sample NetCDF header (what ncdump -h would print) for the embedded fallback.
# This represents a tiny climate dataset: a 2x2 grid of temperatures over 3
# time steps. Real ncdump output on a real .nc would have the same structure.
module SampleNetCdf
  HEADER = <<-NC
  netcdf sample {
  dimensions:
      time = 3 ;
      lat = 2 ;
      lon = 2 ;
  variables:
      float time(time) ;
          time:units = "days since 2026-01-01" ;
      float temperature(time, lat, lon) ;
          temperature:units = "degC" ;
          temperature:long_name = "surface temperature" ;
  data:

   time = 0, 1, 2 ;

   temperature =
    12.5, 13.0,
    13.2, 13.8,
    14.0, 14.2,
    14.5, 14.9, 15.1, 14.7, 15.3, 15.5 ;
  }
  NC
end

# A tiny parser for the fallback header: extract dimensions and variables.
module NcHeaderParser
  def self.dimensions(header : String) : Hash(String, Int32)
    dims = {} of String => Int32
    in_dims = false
    header.each_line do |line|
      line = line.strip
      if line == "dimensions:"
        in_dims = true
        next
      end
      if in_dims
        # The dimensions section ends as soon as we hit the next section header.
        break if line == "variables:" || line == "data:"
        if m = line.match(/(\w+)\s*=\s*(\d+)\s*;/)
          dims[m[1]] = m[2].to_i
        end
      end
    end
    dims
  end

  def self.variables(header : String) : Array(String)
    vars = [] of String
    in_vars = false
    header.each_line do |line|
      line = line.strip
      if line == "variables:"
        in_vars = true
        next
      end
      if in_vars
        break if line == "data:"
        if m = line.match(/^\w+\s+(\w+)\s*\(/)
          vars << m[1]
        end
      end
    end
    vars
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== NetCDF via ncdump ==="

nc_path = "/tmp/crystal_netcdf_009.nc"

# 1. Try the real ncdump path on a .nc file (if one exists).
if File.exists?(nc_path)
  ok, out = NcDump.header(nc_path)
  if ok
    puts "  ncdump -h output:"
    puts out
  else
    puts "  #{out}"
  end
else
  puts "  (no .nc file at #{nc_path}; using embedded sample header)"
end

# 2. Always also show the embedded sample header (works without ncdump).
puts "\n=== embedded sample NetCDF header ==="
puts SampleNetCdf::HEADER

# 3. Parse the sample header: dimensions and variables.
puts "\n=== parsed dimensions ==="
dims = NcHeaderParser.dimensions(SampleNetCdf::HEADER)
dims.each { |k, v| puts "  #{k}: #{v}" }

puts "\n=== parsed variables ==="
NcHeaderParser.variables(SampleNetCdf::HEADER).each { |v| puts "  #{v}" }

# 4. Compute total data points (product of dimension sizes).
total = dims.values.product
puts "\n  total data points in 'temperature': #{total} (time*lat*lon)"

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: check whether ncdump is installed --------------------------
def exercise_1
  ok, _ = NcDump.header("/dev/null")
  puts "Exercise 1 -> ncdump available? #{ok}"
end

# --- Exercise 2: extract the 'time' dimension's size ------------------------
def exercise_2
  dims = NcHeaderParser.dimensions(SampleNetCdf::HEADER)
  puts "Exercise 2 -> time dimension = #{dims["time"]} (expect 3)"
end

# --- Exercise 3: list all variables in the sample header -------------------
def exercise_3
  vars = NcHeaderParser.variables(SampleNetCdf::HEADER)
  puts "Exercise 3 -> variables: #{vars} (expect [time, temperature])"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
