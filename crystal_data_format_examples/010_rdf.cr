# 010_rdf.cr
# ---------------------------------------------------------------------------
# Format: RDF (Resource Description Framework - semantic-web triples)
# ---------------------------------------------------------------------------
# ELI5:
#   RDF describes the world as triples: (subject, predicate, object) - e.g.
#   (alice, knows, bob). It's the data model behind the semantic web and
#   knowledge graphs. There's no first-class Crystal stdlib support; the table
#   says "Manual or HTTP". The simplest textual RDF format is N-Triples: one
#   triple per line, each term a URI <...> or a literal "...".
#
# Best approach (per the table): manual parser + serializer (N-Triples), and
#   optionally an HTTP client to talk to a Fuseki SPARQL endpoint.
#
# Run:  crystal 010_rdf.cr       (Crystal 1.x, stdlib only; HTTP exercise needs a Fuseki server)
# ---------------------------------------------------------------------------

require "http/client"

# A single RDF triple: subject -> predicate -> object.
record Triple, subject : String, predicate : String, object : String do
  # Serialize to the N-Triples line format: <subj> <pred> "obj" .  (or <obj> for URIs)
  def to_nt : String
    obj_str = object.starts_with?("<") || object.starts_with?("_:") ? object : %("#{object}")
    "#{subject} #{predicate} #{obj_str} ."
  end
end

# A tiny N-Triples parser + serializer.
module NtParser
  # Parse one line of N-Triples into a Triple (or nil if blank/malformed).
  def self.parse_line(line : String) : Triple?
    line = line.strip
    return nil if line.empty? || line.starts_with?("#")
    # A line looks like: <s> <p> <o> .  OR  <s> <p> "lit" .
    # Drop the trailing " ." and split on spaces (respecting quotes).
    return nil unless line.ends_with?(".")
    body = line[0...-1].strip
    # Extract the three terms. We use a simple scan for <...> or "...".
    terms = extract_terms(body)
    return nil if terms.size != 3
    Triple.new(terms[0], terms[1], terms[2])
  end

  # Parse a whole N-Triples document into an array of Triples.
  def self.parse(nt : String) : Array(Triple)
    nt.lines.compact_map { |l| parse_line(l) }
  end

  # Serialize an array of Triples back to N-Triples text.
  def self.serialize(triples : Array(Triple)) : String
    triples.map(&.to_nt).join("\n") + "\n"
  end

  # Extract <uri>, _:bnode, or "literal" terms from a string.
  private def self.extract_terms(s : String) : Array(String)
    terms = [] of String
    i = 0
    while i < s.size
      case s[i]
      when '<', '"', '_'
        # Find the matching close (for '"', respecting escapes; for '<', the next '>')
        if s[i] == '<'
          j = s.index('>', i + 1)
          return terms unless j
          terms << s[i..j]
          i = j + 1
        elsif s[i] == '"'
          j = find_unescaped_quote(s, i + 1)
          return terms unless j
          terms << s[i..j]
          i = j + 1
        else # '_' (blank node _:x)
          # Find the next whitespace at or after i+2.
          j = (i + 2...s.size).find { |k| s[k].whitespace? } || s.size
          terms << s[i...j]
          i = j
        end
      else
        i += 1
      end
      # Skip whitespace between terms.
      while i < s.size && s[i].whitespace?
        i += 1
      end
    end
    terms
  end

  private def self.find_unescaped_quote(s : String, from : Int) : Int32?
    i = from
    while i < s.size
      if s[i] == '\\' && i + 1 < s.size
        i += 2
      elsif s[i] == '"'
        return i
      else
        i += 1
      end
    end
    nil
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== RDF (N-Triples manual) ==="

nt = <<-NT
  <http://example.org/alice> <http://xmlns.com/foaf/0.1/name> "Alice Smith" .
  <http://example.org/alice> <http://xmlns.com/foaf/0.1/knows> <http://example.org/bob> .
  <http://example.org/bob> <http://xmlns.com/foaf/0.1/name> "Bob Jones" .
  <http://example.org/bob> <http://example.org/foaf/0.1/age> "30" .
NT

triples = NtParser.parse(nt)
puts "parsed #{triples.size} triples:"
triples.each { |t| puts "  #{t.subject} #{t.predicate} #{t.object}" }

# Round-trip: serialize back and reparse.
reparsed = NtParser.parse(NtParser.serialize(triples))
puts "\nround-trip identical? #{triples == reparsed} (#{reparsed.size} triples)"

# Query: everyone alice knows.
puts "\nalice knows:"
triples.select { |t| t.subject == "<http://example.org/alice>" && t.predicate =~ /knows/ }.each do |t|
  puts "  #{t.object}"
end

# --- HTTP to a Fuseki SPARQL endpoint (optional) -----------------------------
puts "\n=== Fuseki SPARQL endpoint (optional) ==="
puts "  To query a real Fuseki server, set SPARQL_ENDPOINT and run this query:"
sparql = "SELECT ?s ?p ?o WHERE { ?s ?p ?o } LIMIT 5"
puts "  SPARQL: #{sparql}"
puts "  Crystal: HTTP::Client.get(ENV[\"SPARQL_ENDPOINT\"] + \"?query=#{URI.encode(sparql)}\")"
# (Not run live - needs a Fuseki server. The parser above is the runnable part.)

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: parse a single N-Triples line ------------------------------
def exercise_1
  t = NtParser.parse_line(%(<http://x/a> <http://x/p> "hello" .))
  puts "Exercise 1 -> parsed: subject=#{t.try(&.subject)}, object=#{t.try(&.object)} (expect <http://x/a> and \"hello\")"
end

# --- Exercise 2: serialize a Triple and reparse it --------------------------
def exercise_2
  t = Triple.new("<http://x/a>", "<http://x/p>", "hello")
  line = t.to_nt
  reparsed = NtParser.parse_line(line)
  puts "Exercise 2 -> round-trip match? #{reparsed == t}"
end

# --- Exercise 3: filter triples by predicate --------------------------------
def exercise_3
  nt = %(<a:s> <a:p1> "x" .\n<a:s> <a:p2> "y" .\n<a:s> <a:p1> "z" .\n)
  triples = NtParser.parse(nt)
  count = triples.count { |t| t.predicate == "<a:p1>" }
  puts "Exercise 3 -> triples with predicate p1: #{count} (expect 2)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
