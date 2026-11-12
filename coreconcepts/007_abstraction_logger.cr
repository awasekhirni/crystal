# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: A power outlet has a standard shape. Lamps, phones and laptops all plug in and they
# obey the "plug" contract. A crystal module with abstract methods is like that
# standard outlet. An abstraction many classes implement.

module Logger
  abstract def log(message : String) : Nil
end

class ConsoleLogger
  include Logger
  def log(message : String) : Nil
    puts "[console] #{message}"
  end
end

class MemoryLogger
  include Logger

  # only MemoryLogger needs to remember things, so we keep a buffer here
  @buffer = [] of String
  getter buffer

  def log(message : String) : Nil
    @buffer << message
  end
end

# composite logger shows how abstractions compose: it is a logger and contains loggers
class TeeLogger
  include Logger
  def initialize(@loggers : Array(Logger)); end

  def log(message : String) : Nil
    @loggers.each(&.log(message))
  end
end

# Client depends on the abstraction only
def do_work(logger : Logger)
  logger.log("Starting")
  logger.log("Done")
end

# ---- Execution ----------------------------------------------------------
mem = MemoryLogger.new
do_work(TeeLogger.new([ConsoleLogger.new, mem] of Logger))

puts "Captured in memory:"
puts mem.buffer

# =============================================================================
# EXERCISE 1
#   Add a FileLogger that appends to a temp file, then verify the file
#   exists after do_work.
# SOLUTION 1:
#   class FileLogger
#     include Logger
#     def initialize(@path : String); end
#     def log(m : String) : Nil
#       File.open(@path, "a") { |f| f.puts m }
#     end
#   end
#   FileLogger.new("/tmp/crystal.log").tap { |l| do_work(l) }
#   puts File.exists?("/tmp/crystal.log")
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a `NullLogger` that silently does nothing (useful for tests).
# SOLUTION 2:
#   class NullLogger
#     include Logger
#     def log(message : String) : Nil; end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add `log_many` to the module as a non-abstract "default" method.
# SOLUTION 3:
#   module Logger
#     abstract def log(message : String) : Nil
#     def log_many(msgs : Array(String))
#       msgs.each { |m| log(m) }
#     end
#   end
# =============================================================================

#
