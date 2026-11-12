# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Dependency Inversion Principles (DIP): All high-level code should depend
# on abstractions not on the concretes. A light switch doesnt care what kind of light bulb it powers it just needs a socket.
#

# --- Bad: NotificationService directly constructs EmailClient ---------------
#
#   class NotificationService
#     def notify(msg)
#       EmailClient.new.send(msg)   # tight coupling, hard to test
#     end
#   end

# --- Good: depend on a Notifier abstraction --------------------------------
module Notifier
  abstract def notify(message : String) : Nil
end

class EmailNotifier
  include Notifier
  def notify(message : String) : Nil
    puts "[email] #{message}"
  end
end

class SMSNotifier
  include Notifier
  def notify(message : String) : Nil
    puts "[sms]   #{message}"
  end
end

# High-level service depends on the abstraction. It receives its collaborator
# via constructor injection, so tests can supply fakes.
class NotificationService
  def initialize(@notifier : Notifier); end
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
