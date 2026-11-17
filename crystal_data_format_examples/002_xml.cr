# 002_xml.cr
# ---------------------------------------------------------------------------
# Format: XML (stdlib XML.parse + XML.build)
# ---------------------------------------------------------------------------
# ELI5:
#   XML wraps data in nested tags like <book><title>...</title></book>. It's
#   verbose but self-describing and schema-friendly (think: config files, SOAP,
#   RSS feeds, Office documents). Crystal's stdlib has both a parser (XML.parse
#   builds a DOM tree of XML::Node) and a builder (XML.build streams tags out).
#
# Best approach (per the table): `XML.parse`, `XML.build` (stdlib).
#
# Run:  crystal 002_xml.cr       (Crystal 1.x, stdlib only)
# ---------------------------------------------------------------------------

require "xml"

# --- 1. Parse an XML string into a DOM --------------------------------------
xml = <<-XML
  <library>
    <book id="b1" lang="en">
      <title>The Pragmatic Programmer</title>
      <author>Hunt & Thomas</author>
      <year>1999</year>
    </book>
    <book id="b2" lang="en">
      <title>Crystal Programming</title>
      <author>Ary</author>
      <year>2020</year>
    </book>
  </library>
XML

doc = XML.parse(xml)
puts "=== parsed XML root: #{doc.root.try(&.name)} ==="

# --- 2. XPath queries (find nodes by path) ----------------------------------
puts "\n=== XPath: all book titles ==="
doc.xpath_nodes("//book/title").each do |node|
  puts "  #{node.text}"
end

puts "\n=== XPath: first book's id attribute ==="
first_id = doc.xpath_string("string(//book[1]/@id)")
puts "  id=#{first_id}"

# --- 3. Walk children of an element ------------------------------------------
puts "\n=== walking the library element's children ==="
if root = doc.root
  root.children.each do |child|
    next unless child.element?
    puts "  <#{child.name}>"
    child.children.each do |gc|
      next unless gc.element?
      puts "    <#{gc.name}>#{gc.text}</#{gc.name}>"
    end
  end
end

# --- 4. Build XML programmatically with XML.build ---------------------------
puts "\n=== XML.build (programmatic) ==="
built = XML.build(indent: 2) do |xml|
  xml.element("people") do
    xml.element("person", id: 1) do
      xml.element("name") { xml.text "Ada Lovelace" }
      xml.element("born") { xml.text "1815" }
    end
    xml.element("person", id: 2) do
      xml.element("name") { xml.text "Grace Hopper" }
      xml.element("born") { xml.text "1906" }
    end
  end
end
puts built

# --- 5. Parse what we just built (round-trip) -------------------------------
reparsed = XML.parse(built)
count = reparsed.xpath_nodes("//person").size
puts "\n=== round-trip: reparsed #{count} <person> elements ==="

# --- 6. XML.escape: safely embed special chars (<, >, &) -------------------
puts "\n=== XML.escape ==="
raw = "a < b && b > c"
puts "  raw    : #{raw}"
puts "  escaped: #{XML.escape(raw)}"

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: find the year of the second book ---------------------------
def exercise_1
  doc = XML.parse(%(<books><book><year>1999</year></book><book><year>2020</year></book></books>))
  year = doc.xpath_string("string(//book[2]/year)")
  puts "Exercise 1 -> second book year: #{year} (expect 2020)"
end

# --- Exercise 2: build XML for a list of 3 items ----------------------------
def exercise_2
  items = ["apple", "banana", "cherry"]
  xml = XML.build do |x|
    x.element("list") do
      items.each { |i| x.element("item") { x.text i } }
    end
  end
  reparsed = XML.parse(xml)
  count = reparsed.xpath_nodes("//item").size
  puts "Exercise 2 -> built XML with #{count} <item> nodes (expect 3)"
  puts "            #{xml}"
end

# --- Exercise 3: count elements named "author" -------------------------------
def exercise_3
  doc = XML.parse(%(<r><author>A</author><author>B</author><author>C</author></r>))
  count = doc.xpath_nodes("//author").size
  puts "Exercise 3 -> found #{count} <author> elements (expect 3)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
