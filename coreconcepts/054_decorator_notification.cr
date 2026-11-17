# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5:
#   You send a notification — maybe also by email, also by SMS, also logged
#   to a file. Each channel "wraps" the send. A decorator lets you add
#   channels without modifying the core notifier or the call site.
#
# SETUP:
#   crystal run 054_decorator_notification.cr
# =============================================================================

# Module `Notifier`.
module Notifier
  # Send a message through this client/socket.
  abstract def send(msg : String) : Nil
end

# Concrete class `ConsoleNotifier`.
class ConsoleNotifier
  include Notifier
  # Send a message through this client/socket.
  def send(msg : String) : Nil; puts "[console] #{msg}"; end
end

# --- Abstract decorator ----------------------------------------------------
abstract class NotifierDecorator
  include Notifier
  def initialize(@inner : Notifier); end
  # Send a message through this client/socket.
  def send(msg : String) : Nil; @inner.send(msg); end
end

# --- Concrete decorators (fan-out to a second channel) --------------------
class EmailNotifier < NotifierDecorator
  # Send a message through this client/socket.
  def send(msg : String) : Nil
    super
    puts "[email]   #{msg}"
  end
end

# Concrete class `SmsNotifier` -- extends NotifierDecorator.
class SmsNotifier < NotifierDecorator
  # Send a message through this client/socket.
  def send(msg : String) : Nil
    super
    puts "[sms]     #{msg}"
  end
end

# Concrete class `SlackNotifier` -- extends NotifierDecorator.
class SlackNotifier < NotifierDecorator
  # Send a message through this client/socket.
  def send(msg : String) : Nil
    super
    puts "[slack]   #{msg}"
  end
end

# --- A filtering decorator (skip certain messages) -----------------------
class FilteredNotifier < NotifierDecorator
  def initialize(inner : Notifier, @ignore : String); super(inner); end
  # Send a message through this client/socket.
  def send(msg : String) : Nil
    return if msg.includes?(@ignore)
    super
  end
end

# ---- Demonstration ----------------------------------------------------------
notifier : Notifier = SmsNotifier.new(EmailNotifier.new(ConsoleNotifier.new))
notifier.send("deploy done")

filtered : Notifier = FilteredNotifier.new(SlackNotifier.new(ConsoleNotifier.new), "SECRET")
filtered.send("normal message")
filtered.send("this contains SECRET; skipped")

# =============================================================================
# EXERCISE 1
#   Add a "batching" decorator that groups messages and flushes on "#flush".
# SOLUTION 1:
#   class BatchingNotifier < NotifierDecorator
#     @pending = [] of String
#     def send(msg)
#       if msg == "#flush"
#         @pending.each { |m| super(m) }
#         @pending.clear
#       else
#         @pending << msg
#       end
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a severity-based decorator that forwards only errors.
# SOLUTION 2:
#   class ErrorOnly < NotifierDecorator
#     def send(msg); super if msg.starts_with?("ERROR"); end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Given decorators: [Email, Sms], show how to add a "retry on exception"
#   without touching existing decorators.
# SOLUTION 3:
#   class RetryingNotifier < NotifierDecorator
#     def initialize(inner, @attempts = 3); super(inner); end
#     def send(msg)
#       t = 0
#       begin; t += 1; super
#       rescue e
#         raise e if t >= @attempts
#         retry
#       end
#     end
#   end
#   Wrap outermost so retries cover the whole chain.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
