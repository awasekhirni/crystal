# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:Single Responsibility Principle - A chef shouldn't also be a the cashier, the cleaner, adn the delivery guy.
# one job per person. each class should have exactly one reason to change
#

# a class which does 3 jobs such as build report, save, email
class Report
  def generate; "content method"; end
  def save_to_disk(path : String); file.write(path,generate); end
  def email(to : String); puts "Emailed to #{to}"; end
end

#change in email formatting would touch a class that also knows about disk i/o operations and report generation
#
#
# implementating SRP compliant class- each class has a single reason to change.

# report that owns content only
class ContentReport
  getter title, body
  def initialize(@title : String, @body : String); end
  def to_s(io : IO) : Nil; io << "#{@title}\n#{@body}"; end
end

# report savers owns persistence
class ReportSaver
  def save (report : ContentReport, path : String) : Nil
    File.write(path, report.to_s)
  end
end

#reportmailer owns delivery
class ReportMailer
  def deliver(report : ContentReport, to : String) : Nil
    puts "Emailed '#{report.title}' to #{to}"
  end
end

# ---- Execution ----------------------------------------------------------
report = ContentReport.new("Q1", "All good.")
ReportSaver.new.save(report, "/tmp/q1.txt")
ReportMailer.new.deliver(report, "controlz@betaori.com")
puts File.read("/tmp/q1.txt")

# =============================================================================
# EXERCISE 1
#   Add PDFReportPrinter as a new responsibility; leave Report untouched.
# SOLUTION 1:
#   class ReportPrinter
#     def print(report : Report) : Nil; puts "PDF: #{report.title}"; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Swap ReportSaver for an in-memory saver in tests without changing
#   Report. Introduce a `Saver` module.
# SOLUTION 2:
#   module Saver; abstract def save(r : Report, path : String) : Nil; end
#   class MemorySaver; include Saver
#     getter items = [] of Report
#     def save(r : Report, path : String) : Nil; @items << r; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Identify the three reasons Report originally had to change.
# SOLUTION 3:
#   (a) content format changes (layout), (b) storage mechanism changes
#   (file → DB), (c) delivery mechanism changes (SMTP → API).
# =============================================================================
