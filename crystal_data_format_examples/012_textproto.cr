# 012_textproto.cr
# ---------------------------------------------------------------------------
# Format: TextProto (Google's text format for protobuf messages)
# ---------------------------------------------------------------------------
# ELI5:
#   Protobuf (011) is binary. TextProto is the human-readable sibling: instead of
#   packed bytes, it's a nested `key: value` format with braces for sub-messages
#   and square brackets for repeated fields. It's how you write a .proto's test
#   data by hand. Example:
#       name: "Alice"
#       age: 30
#       emails: ["a@x.com", "b@x.com"]
#       address { street: "5 Main" city: "NYC" }
#   The table says "Simple manual parser" - there's no stdlib support; we build
#   a small recursive-descent parser that turns TextProto into a nested Hash.
#
# Best approach (per the table): simple manual parser (stdlib).
#
# Run:  crystal 012_textproto.cr       (Crystal 1.x, stdlib only)
# ---------------------------------------------------------------------------

require "json"   # only for pretty-printing the parsed result

# A TextProto value is either a String, an Array(TextProtoValue), or a Hash(String, TextProtoValue).
alias TPValue = String | Array(TPValue) | Hash(String, TPValue)

module TextProto
  # Parse a TextProto document into a Hash(String, TPValue).
  def self.parse(text : String) : Hash(String, TPValue)
    parser = Parser.new(text)
    parser.parse_message
  end

  # Serialize a Hash back to TextProto text.
  def self.serialize(obj : Hash(String, TPValue), indent = 0) : String
    pad = "  " * indent
    String.build do |s|
      obj.each do |k, v|
        case v
        when Hash
          s << "#{pad}#{k} {\n"
          s << serialize(v, indent + 1)
          s << "#{pad}}\n"
        when Array
          items = v.map { |item| serialize_scalar(item) }
          s << "#{pad}#{k}: [#{items.join(", ")}]\n"
        else
          s << "#{pad}#{k}: #{serialize_scalar(v)}\n"
        end
      end
    end
  end

  private def self.serialize_scalar(v) : String
    case v
    when String
      # Quote if it contains spaces or special chars.
      if v.any? { |c| c.whitespace? || c == '"' || c == ':' }
        %("#{v.gsub('"', "\\\"")}")
      else
        v
      end
    else
      v.to_s
    end
  end

  # A tiny recursive-descent parser.
  private class Parser
    @pos = 0
    @text : String

    def initialize(@text); end

    def parse_message : Hash(String, TPValue)
      result = {} of String => TPValue
      skip_whitespace_and_comments
      while @pos < @text.size && @text[@pos] != '}'
        key = parse_key
        skip_whitespace
        # Now we expect ':', '{', or '['.
        if @text[@pos] == '{'
          @pos += 1
          skip_whitespace_and_comments
          sub = parse_message
          @pos += 1 if @pos < @text.size && @text[@pos] == '}'
          result[key] = sub
        elsif @text[@pos] == ':'
          @pos += 1
          skip_whitespace
          val = parse_value
          # If the key already exists and is an array, append; else store.
          if existing = result[key]?
            if existing.is_a?(Array)
              existing << val
            else
              result[key] = [existing, val] of TPValue
            end
          else
            result[key] = val
          end
        else
          # Bare key without value (rare); skip.
          @pos += 1
        end
        skip_whitespace_and_comments
      end
      result
    end

    private def parse_key : String
      start = @pos
      while @pos < @text.size && (@text[@pos].alphanumeric? || @text[@pos] == '_')
        @pos += 1
      end
      @text[start...@pos]
    end

    private def parse_value : TPValue
      case c = @text[@pos]
      when '"'
        parse_string
      when '['
        parse_array
      when '{'
        @pos += 1
        skip_whitespace_and_comments
        sub = parse_message
        @pos += 1 if @pos < @text.size && @text[@pos] == '}'
        sub
      else
        # Bare scalar (number or identifier).
        parse_scalar
      end
    end

    private def parse_string : String
      @pos += 1  # skip opening quote
      start = @pos
      while @pos < @text.size && @text[@pos] != '"'
        if @text[@pos] == '\\' && @pos + 1 < @text.size
          @pos += 2
        else
          @pos += 1
        end
      end
      val = @text[start...@pos]
      @pos += 1  # skip closing quote
      val
    end

    private def parse_array : Array(TPValue)
      @pos += 1  # skip '['
      items = [] of TPValue
      skip_whitespace_and_comments
      while @pos < @text.size && @text[@pos] != ']'
        items << parse_value
        skip_whitespace_and_comments
        if @pos < @text.size && @text[@pos] == ','
          @pos += 1
          skip_whitespace_and_comments
        end
      end
      @pos += 1  # skip ']'
      items
    end

    private def parse_scalar : String
      start = @pos
      while @pos < @text.size && !@text[@pos].whitespace? && @text[@pos] != '}' && @text[@pos] != ']' && @text[@pos] != ','
        @pos += 1
      end
      @text[start...@pos]
    end

    private def skip_whitespace_and_comments
      while @pos < @text.size
        c = @text[@pos]
        if c.whitespace?
          @pos += 1
        elsif c == '#'
          # Comment to end of line.
          while @pos < @text.size && @text[@pos] != '\n'
            @pos += 1
          end
        else
          break
        end
      end
    end

    private def skip_whitespace
      while @pos < @text.size && @text[@pos].whitespace?
        @pos += 1
      end
    end
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== TextProto (manual parser) ==="

tp = <<-TP
  name: "Alice Smith"
  age: 30
  active: true
  emails: ["alice@x.com", "alice@y.com"]
  address {
    street: "5 Main St"
    city: "NYC"
    zip: "10001"
  }
  # This is a comment
  score: 95.5
TP

parsed = TextProto.parse(tp)
puts "parsed (as JSON for readability):"
puts parsed.to_pretty_json

puts "\n=== round-trip: serialize back ==="
serialized = TextProto.serialize(parsed)
puts serialized

# Verify the round-trip preserves the data.
reparsed = TextProto.parse(serialized)
puts "round-trip identical? #{parsed == reparsed}"

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: parse a simple key:value pair -----------------------------
def exercise_1
  h = TextProto.parse(%(name: "Bob"))
  puts "Exercise 1 -> name = #{h["name"]} (expect Bob)"
end

# --- Exercise 2: parse an array field --------------------------------------
def exercise_2
  h = TextProto.parse(%(tags: ["a", "b", "c"]))
  tags = h["tags"].as(Array).map(&.to_s)
  puts "Exercise 2 -> tags = #{tags} (expect [a, b, c])"
end

# --- Exercise 3: parse a nested message ------------------------------------
def exercise_3
  tp = "person { name: \"Alice\" }"
  h = TextProto.parse(tp)
  person = h["person"].as(Hash)
  puts "Exercise 3 -> nested name = #{person["name"]} (expect Alice)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
