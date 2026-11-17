# 007_pdf.cr
# ---------------------------------------------------------------------------
# Format: PDF (Portable Document Format - needs a shard to generate)
# ---------------------------------------------------------------------------
# ELI5:
#   PDF is a precise page-description format: text positioned at exact
#   coordinates, fonts embedded, vector graphics. Hand-writing PDF bytecode is
#   painful. The `pdf` shard (crystal-pdf) gives you a Document/Page/Font API:
#   create a page, set a font, draw text at (x, y), save. The output is a real
#   .pdf a viewer can open.
#
# Best approach (per the table): a shard for generation (the `pdf` shard).
#
#   Because the shard must be installed via `shards install`, the demo is
#   wrapped so it explains what to do and falls back to a printable text/HTML
#   representation when the shard isn't present.
#
# Run:  (1) add `pdf` to shard.yml, (2) `shards install`, (3) `crystal 007_pdf.cr`
# ---------------------------------------------------------------------------

# When the shard is installed (see README), uncomment the require below:
# require "pdf"

module PdfExample
  # Build a one-page PDF report. With the shard:
  #   doc = PDF::Document.new(page_size: "A4")
  #   page = doc.pages.first
  #   page.font = doc.fonts.create("Helvetica")
  #   page.text("Quarterly Report", x: 50, y: 780, size: 24)
  #   page.text("Revenue: $1.2M", x: 50, y: 750, size: 12)
  #   doc.save(path)
  def self.build_report(path : String) : String
    puts "  (pdf shard not installed - writing HTML fallback at #{path}.html)"
    html_path = "#{path}.html"
    html = <<-HTML
      <!DOCTYPE html>
      <html><head><title>Quarterly Report</title></head>
      <body>
        <h1 style="font-family:Helvetica;font-size:24pt;">Quarterly Report</h1>
        <p style="font-family:Helvetica;font-size:12pt;">Revenue: $1.2M</p>
        <p style="font-family:Helvetica;font-size:12pt;">Net income: $240K</p>
        <p style="font-family:Helvetica;font-size:12pt;">Generated: 2026-01-01</p>
      </body></html>
    HTML
    File.write(html_path, html)
    html_path
  end

  # A "read" of a PDF is really text extraction; the shard would expose
  # doc.pages.map(&.text). For the fallback we report the file exists.
  def self.extract_text(path : String) : String
    html_path = path.ends_with?(".html") ? path : "#{path}.html"
    return "(file not found)" unless File.exists?(html_path)
    File.read(html_path)
  end
end

# ---------------------------------------------------------------------------
# Demonstrative main
# ---------------------------------------------------------------------------
puts "=== PDF (pdf shard) ==="
puts "  To enable real .pdf output: add `pdf` to shard.yml and run `shards install`."
puts ""

dest = "/tmp/crystal_pdf_007.pdf"
written = PdfExample.build_report(dest)
puts "  wrote: #{written}"

puts "\n=== extracted text ==="
text = PdfExample.extract_text(dest)
# Print just the meaningful lines (strip HTML tags for display).
stripped = text.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
puts "  #{stripped}"

# Cleanup
["#{dest}.html", dest].each { |p| File.delete(p) if File.exists?(p) }

# ---------------------------------------------------------------------------
# EXERCISES
# ---------------------------------------------------------------------------

# --- Exercise 1: build a PDF with 3 pages -----------------------------------
def exercise_1
  # With the shard:
  #   doc = PDF::Document.new
  #   3.times { |i| doc.add_page.text("Page #{i+1}", x: 50, y: 750) }
  #   doc.save("/tmp/ex1.pdf")
  puts "Exercise 1 -> would build a 3-page PDF (fallback: skipped; install the pdf shard)"
end

# --- Exercise 2: draw text at a specific (x, y) coordinate ------------------
def exercise_2
  # With the shard:
  #   page.text("Hello", x: 100, y: 500, size: 16)
  puts "Exercise 2 -> text positioning is via page.text(x:, y:, size:) - install the pdf shard to run"
end

# --- Exercise 3: set the page size to A4 vs Letter --------------------------
def exercise_3
  # With the shard:
  #   PDF::Document.new(page_size: "A4")      # 595 x 842 pt
  #   PDF::Document.new(page_size: "Letter")  # 612 x 792 pt
  puts "Exercise 3 -> A4 = 595x842 pt, Letter = 612x792 pt (PDF point = 1/72 inch)"
end

puts "\n=== Running exercises ==="
exercise_1
exercise_2
exercise_3
