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
#   A simple factory is like a vending machine: you press "coffee" and get
#   coffee — you don't build the coffee yourself. It hides the construction
#   recipe behind one method. NOT a GoF pattern, but an important stepping
#   stone to Factory Method.
#
# SETUP:
#   crystal run 021_simple_factory_notification.cr
# =============================================================================

# Product abstraction.
module Notification
  # Send a message through this client/socket.
  abstract def send(message : String) : String
end

# Concrete class `EmailNotification`.
class EmailNotification
  include Notification
  # Send a message through this client/socket.
  def send(message : String) : String; "email: #{message}"; end
end

# Concrete class `SMSNotification`.
class SMSNotification
  include Notification
  # Send a message through this client/socket.
  def send(message : String) : String; "sms:   #{message}"; end
end

# Concrete class `PushNotification`.
class PushNotification
  include Notification
  # Send a message through this client/socket.
  def send(message : String) : String; "push:  #{message}"; end
end

# Simple factory: a single construction point.
class NotificationFactory
  # Return the result of `self`.
  def self.build(kind : Symbol) : Notification
    case kind
    when :email then EmailNotification.new
    when :sms   then SMSNotification.new
    when :push  then PushNotification.new
    else             raise ArgumentError.new("unknown notification: #{kind}")
    end
  end
end

# ---- Demonstration ----------------------------------------------------------
[:email, :sms, :push].each do |kind|
  n = NotificationFactory.build(kind)
  puts n.send("hello")
end

# =============================================================================
# EXERCISE 1
#   Add :slack without touching the caller loop.
# SOLUTION 1:
#   class SlackNotification
#     include Notification
#     def send(message : String) : String; "slack: #{message}"; end
#   end
#   # Add `when :slack then SlackNotification.new` in build.
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Accept a Hash(Symbol, String) of params to configure the product.
# SOLUTION 2:
#   def self.build(kind : Symbol, params : Hash(Symbol, String) = {} of Symbol => String) : Notification
#     case kind
#     when :email then EmailNotification.new  # (would read params[:to], params[:from])
#     ...
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Explain the main drawback vs the Factory Method pattern.
# SOLUTION 3:
#   Simple factory violates OCP: every new notification type edits the
#   case statement. Factory Method moves that construction into subclass
#   hooks so new types come with new creator subclasses — no central switch.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
