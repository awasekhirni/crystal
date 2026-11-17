# 011_protobuf.cr
# ---------------------------------------------------------------------------
# Format: Protobuf (Protocol Buffers - compact binary serialization)
# ---------------------------------------------------------------------------
# ELI5:
#   JSON is human-readable but verbose. Protobuf is Google's binary format:
#   you write a .proto schema (message Person { string name = 1; int32 age = 2; }),
#   compile it to code with `protoc`, and serialize/deserialize compact bytes.
#   Each field is a (tag, wire-type, value) triple. Smaller, faster than JSON,
#   but you NEED the schema to read it back.
#
# Best approach (per the table): the `protobuf` shard + `protoc`.
#   (deps.yml: protobuf github: jeromegn/protobuf.cr)
#
#   The shard uses `protoc`-generated Crystal modules; you `include Protobuf::Message`
#   and declare fields with `field :name, 1, type: String`. We also show the raw
#   wire-format encoding by hand so the protocol is visible without the shard.
#
# Run:  (1) add `protobuf` to shard.yml, (2) `shards install`, (3) `crystal 011_protobuf.cr`
#       The raw-wire-format demo runs standalone (stdlib only).
# ---------------------------------------------------------------------------

# When the shard is installed, uncomment the require below:
# require "protobuf"

# --- 1. The "shard idiom" (shown as comments; needs `protobuf` installed) ----
#
# class Person
#   include Protobuf::Message
#
#   @[Field(tag: 1)]
#   property name : String
#
#   @[Field(tag: 2)]
#   property age : Int32
#
#   @[Field(tag: 3)]
#   property emails : Array(String) = [] of String
# end
#
# p = Person.new
# p.name = "Alice"
# p.age = 30
# bytes = p.to_protobuf
# back = Person.from_protobuf(bytes)

# --- 2. The raw wire format, hand-encoded (stdlib only) ----------------------
# A varint is a sequence of bytes; the MSB is a "more bytes follow" flag.
module WireFormat
  # Encode an integer as a base-128 varint.
  def self.encode_varint(value : UInt64) : Bytes
    out = IO::Memory.new
    v = value
    loop do
      byte = (v & 0x7F).to_u8
      v >>= 7
      if v == 0
        out.write_byte(byte)
        break
      else
        out.write_byte(byte | 0x80)
      end
    end
    out.to_slice
  end

  # Decode a varint from a slice; returns {value, bytes_consumed}.
  def self.decode_varint(bytes : Bytes, offset = 0) : {UInt64, Int32}
    value = 0_u64
    shift = 0
    i = offset
    loop do
      byte = bytes[i]
      value |= UInt64.new(byte & 0x7F) << shift
      i += 1
      break if (byte & 0x80) == 0
      shift += 7
    end
    {value, i - offset}
  end

  # Encode a length-delimited field (tag, length-prefix, bytes).
  def self.encode_string(tag : Int, value : String) : Bytes
    out = IO::Memory.new
    # Tag = (field_number << 3) | wire_type. wire_type 2 = length-delimited.
    out.write encode_varint(UInt64.new(tag << 3) | 2)
    out.write encode_varint(value.bytesize.to_u64)
    out.write value.to_slice
    out.to_slice
  end

  # Encode a varint field (tag, value). wire_type 0 = varint.
  def self.encode_varint_field(tag : Int, value : UInt64) : Bytes
    out = IO::Memory.new
    out.write encode_varint(UInt64.new(tag << 3) | 0)
    out.write encode_varint(value)
    out.to_slice
  end

  # Decode all fields in a message into a map {tag => {wire_type, raw_bytes}}.
  # For varint fields, raw_bytes is the varint-encoded bytes (not the value).
  def self.decode_message(bytes : Bytes) : Hash(Int32, Tuple(Int32, Bytes))
    fields = {} of Int32 => Tuple(Int32, Bytes)
    i = 0
    while i < bytes.size
      tag_varint, consumed = decode_varint(bytes, i)
      i += consumed
      field_number = (tag_varint >> 3).to_i
      wire_type = (tag_varint & 0x07).to_i
      case wire_type
      when 0 # varint
        val, consumed = decode_varint(bytes, i)
        # Store the varint bytes (so the caller can re-decode or inspect).
        fields[field_number] = {0, bytes[i, consumed]}
        i += consumed
      when 2 # length-delimited
        len, consumed = decode_varint(bytes, i)
        i += consumed
        data = bytes[i, len]
        i += len
        fields[field_number] = {2, data}
      else
        break # unsupported wire type for this demo
      end
    end
    fields
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main (raw wire format, stdlib only)
# ---------------------------------------------------------------------------
puts "=== Protobuf wire format (hand-encoded) ==="

# Build: name (tag 1) = "Alice", age (tag 2) = 30.
msg = IO::Memory.new
msg.write WireFormat.encode_string(1, "Alice")
msg.write WireFormat.encode_varint_field(2, 30_u64)
bytes = msg.to_slice
puts "  encoded message: #{bytes.to_a.inspect} (#{bytes.size} bytes)"
puts "  (compare: JSON '{\"name\":\"Alice\",\"age\":30}' is #{%({"name":"Alice","age":30}).bytesize} bytes)"

# Decode it back.
fields = WireFormat.decode_message(bytes)
puts "\n  decoded fields:"
fields.each do |tag, (wire_type, data)|
  case wire_type
  when 0
    val, _ = WireFormat.decode_varint(data)
    puts "    tag #{tag} (varint): #{val}"
  when 2
    puts "    tag #{tag} (string): #{String.new(data).inspect}"
  end
end

name = String.new(fields[1][1])
age_val, _ = WireFormat.decode_varint(fields[2][1])
puts "\n  round-trip: name=#{name}, age=#{age_val} (expect Alice, 30)"

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: encode a varint and decode it back --------------------------
def exercise_1
  bytes = WireFormat.encode_varint(300_u64)
  val, _ = WireFormat.decode_varint(bytes)
  puts "Exercise 1 -> 300 encodes to #{bytes.to_a.inspect}, decodes to #{val} (match: #{val == 300})"
end

# --- Exercise 2: encode a string field and read it back ---------------------
def exercise_2
  bytes = WireFormat.encode_string(1, "hello")
  fields = WireFormat.decode_message(bytes)
  val = String.new(fields[1][1])
  puts "Exercise 2 -> encoded 'hello' (tag 1), decoded: #{val} (match: #{val == "hello"})"
end

# --- Exercise 3: show that varints are smaller for small numbers ----------
def exercise_3
  sizes = [1, 300, 16384].map { |n| WireFormat.encode_varint(n.to_u64).size }
  puts "Exercise 3 -> varint byte sizes for [1, 300, 16384]: #{sizes} (small numbers = fewer bytes)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
