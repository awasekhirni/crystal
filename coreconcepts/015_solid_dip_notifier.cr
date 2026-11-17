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
#   A light switch doesn't care what kind of light bulb it powers — it just
#   needs a "socket". Dependency Inversion Principle (DIP): high-level code
#   should depend on abstractions (the socket), not on concretes (the bulb).
#
# SETUP:
#   crystal run 015_solid_dip_notifier.cr
# =============================================================================

# --- Bad: NotificationService directly constructs EmailClient ---------------
#
#   class NotificationService
#     def notify(msg)
#       EmailClient.new.send(msg)   # tight coupling, hard to test
#     end
#   end

# --- Good: depend on a Notifier abstraction --------------------------------
module Notifier
  # Return the result of `notify`.
  abstract def notify(message : String) : Nil
end

# Concrete class `EmailNotifier`.
class EmailNotifier
  include Notifier
  # Return the result of `notify`.
  def notify(message : String) : Nil
    puts "[email] #{message}"
  end
end

# Concrete class `SMSNotifier`.
class SMSNotifier
  include Notifier
  # Return the result of `notify`.
  def notify(message : String) : Nil
    puts "[sms]   #{message}"
  end
end

# High-level service depends on the abstraction. It receives its collaborator
# via constructor injection, so tests can supply fakes.
class NotificationService
  def initialize(@notifier : Notifier); end
  # Return the result of `alert`.
  def alert(message : String) : Nil
    @notifier.notify("ALERT: #{message}")
  end
end

# ---- Demonstration ----------------------------------------------------------
NotificationService.new(EmailNotifier.new).alert("disk full")
NotificationService.new(SMSNotifier.new).alert("disk full")

# =============================================================================
# EXERCISE 1
#   Add a SlackNotifier and use it without changing NotificationService.
# SOLUTION 1:
#   class SlackNotifier
#     include Notifier
#     def notify(message : String) : Nil; puts "[slack] #{message}"; end
#   end
#   NotificationService.new(SlackNotifier.new).alert("deploy done")
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a RecordingNotifier fake for tests (records instead of sending).
# SOLUTION 2:
#   class RecordingNotifier
#     include Notifier
#     getter messages = [] of String
#     def notify(message : String) : Nil; @messages << message; end
#   end
#   # Spec-style check:
#   rec = RecordingNotifier.new
#   NotificationService.new(rec).alert("hi")
#   raise "fail" unless rec.messages == ["ALERT: hi"]
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a CompositeNotifier that fans out to several notifiers — still DIP-safe.
# SOLUTION 3:
#   class CompositeNotifier
#     include Notifier
#     def initialize(@notifiers : Array(Notifier)); end
#     def notify(message : String) : Nil
#       @notifiers.each(&.notify(message))
#     end
#   end
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
