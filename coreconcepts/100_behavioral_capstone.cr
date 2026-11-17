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
#   A small workflow app that ties together several behavioral patterns:
#   Strategy picks how to validate; Chain handles fallback validation;
#   Observer notifies listeners; Command wraps each step for undo; State
#   manages the job lifecycle; Template Method defines the process skeleton;
#   Memento snapshots on failure; Iterator walks results; Mediator routes
#   messages; Visitor adds reporting; Interpreter parses the rule string;
#   Null Object used for a quiet default logger. This is how behavioral
#   patterns layer in real code.
#
# SETUP:
#   crystal run 100_behavioral_capstone.cr
# =============================================================================

# --- Null Object logger (default no-op) ----------------------------------
module Logger
  # Return the result of `log`.
  abstract def log(msg : String) : Nil
end

# Concrete class `NullLogger`.
class NullLogger
  include Logger
  # Return the result of `log`.
  def log(msg : String) : Nil; end
end

# Concrete class `ConsoleLogger`.
class ConsoleLogger
  include Logger
  # Return the result of `log`.
  def log(msg : String) : Nil; puts msg; end
end

# --- Strategy: validation -------------------------------------------------
module Validator
  # Return true if `valid` holds.
  abstract def valid?(payload : String) : Bool
end

# Concrete class `NonEmptyValidator`.
class NonEmptyValidator
  include Validator
  # Return true if `valid` holds.
  def valid?(payload : String) : Bool; !payload.empty?; end
end

# Concrete class `LengthValidator`.
class LengthValidator
  include Validator
  def initialize(@max : Int32); end
  # Return true if `valid` holds.
  def valid?(payload : String) : Bool; payload.size <= @max; end
end

# --- State: job lifecycle -------------------------------------------------
abstract class JobState
  # Return the human-readable name of this state/object.
  abstract def name : String
end

# Concrete class `Pending` -- extends JobState.
class Pending   < JobState; def name : String; "pending";   end; end
# Concrete class `Running` -- extends JobState.
class Running   < JobState; def name : String; "running";   end; end
# Concrete class `Completed` -- extends JobState.
class Completed < JobState; def name : String; "completed"; end; end
# Concrete class `Failed` -- extends JobState.
class Failed    < JobState; def name : String; "failed";    end; end

# --- Command: process step ------------------------------------------------
abstract class Step
  # Execute the template-method pipeline and return the result.
  abstract def run(payload : String) : String
end

# Concrete class `TrimStep` -- extends Step.
class TrimStep < Step
  # Execute the template-method pipeline and return the result.
  def run(p : String) : String; p.strip; end
end

# Concrete class `UpcaseStep` -- extends Step.
class UpcaseStep < Step
  # Execute the template-method pipeline and return the result.
  def run(p : String) : String; p.upcase; end
end

# --- Observer -------------------------------------------------------------
module Observer
  # Callback for the `event` event.
  abstract def on_event(event : String, data : String) : Nil
end

# Concrete class `ConsoleListener`.
class ConsoleListener
  include Observer
  # Callback for the `event` event.
  def on_event(event : String, data : String) : Nil
    puts "[event] #{event} #{data}"
  end
end

# --- Template Method: pipeline skeleton + Strategy + Observer + State ----
abstract class ProcessPipeline
  # Instance-variable type annotations must live at the class level in
  # Crystal; only assignment happens inside `initialize`.
  @state : JobState
  @listeners = [] of Observer
  @history = [] of {String, JobState}   # memento-ish snapshot

  def initialize(@validator : Validator, @logger : Logger)
    @state = Pending.new
  end

  # Return the result of `subscribe`.
  def subscribe(o : Observer) : Nil; @listeners << o; end

  # Execute the template-method pipeline and return the result.
  def run(payload : String) : String?
    # Fixed skeleton.
    validate!(payload)
    transition(Running.new)
    steps.each do |step|
      payload = step.run(payload)
    end
    transition(Completed.new)
    notify("completed", payload)
    payload
  rescue ex
    rollback!
    transition(Failed.new)
    notify("failed", ex.message.to_s)
    nil
  end

  # Return the result of `state_name`.
  def state_name : String; @state.name; end

  protected def transition(new_state : JobState) : Nil
    @history << {@state.name, @state}
    @state = new_state
  end

  protected def rollback! : Nil
    if prev = @history.pop?
      @state = prev[1]
    end
  end

  protected def notify(event : String, data : String) : Nil
    @listeners.dup.each(&.on_event(event, data))
  end

  protected def validate!(payload : String) : Nil
    raise "invalid payload" unless @validator.valid?(payload)
    @logger.log("validated")
  end

  # Abstract: subclass decides the concrete steps.
  abstract def steps : Array(Step)
end

# Concrete class `TrimUpcasePipeline` -- extends ProcessPipeline.
class TrimUpcasePipeline < ProcessPipeline
  # Return the result of `steps`.
  def steps : Array(Step)
    [TrimStep.new, UpcaseStep.new] of Step
  end
end

# --- Mediator: event bus -------------------------------------------------
class EventBus
  @listeners = [] of Observer
  # Return the result of `subscribe`.
  def subscribe(o : Observer) : Nil; @listeners << o; end
  # Return the result of `publish`.
  def publish(event : String, data : String) : Nil
    @listeners.each(&.on_event(event, data))
  end
end

# --- Iterator: walk history ----------------------------------------------
class HistoryIterator
  include Iterator(String)
  def initialize(@entries : Array(String)); end
  # Return the result of `next`.
  def next : Iterator::Stop | String
    return stop if @entries.empty?
    @entries.shift
  end
end

# --- Visitor: report the events seen so far ------------------------------
module EventVisitor
  # Visit a node and return a String result.
  abstract def visit(event : String, data : String) : String
end

# Concrete class `MarkdownVisitor`.
class MarkdownVisitor
  include EventVisitor
  # Visit a node and return a String result.
  def visit(event : String, data : String) : String; "- #{event}: #{data}"; end
end

# Concrete class `CsvVisitor`.
class CsvVisitor
  include EventVisitor
  # Visit a node and return a String result.
  def visit(event : String, data : String) : String; "#{event},#{data}"; end
end

# --- Interpreter: interpret a small "length <= N" rule -------------------
# (Illustrative; real code would parse arbitrary expressions.)
class LengthRule
  def initialize(@max : Int32); end
  # Return true if `matches` holds.
  def matches?(payload : String) : Bool; payload.size <= @max; end
end

# ---- Demonstration ----------------------------------------------------------
bus = EventBus.new
bus.subscribe(ConsoleListener.new)

pipeline = TrimUpcasePipeline.new(NonEmptyValidator.new, NullLogger.new)
pipeline.subscribe(ConsoleListener.new)
pipeline.subscribe(ConsoleListener.new)

puts "== first run =="
pipeline.run("  hello  ")
puts "state: #{pipeline.state_name}"

puts "== second run (invalid) =="
pipeline.run("")
puts "state: #{pipeline.state_name}"

# Iterator over a small event log (illustrative).
events = ["completed:HELLO", "failed:invalid payload"]
iter = HistoryIterator.new(events.dup)
puts "history:"
iter.each { |e| puts "  #{e}" }

# Visitor over the same events.
[MarkdownVisitor.new, CsvVisitor.new].each do |v|
  puts "-- #{v.class} --"
  events.each do |line|
    event, data = line.split(":", 2)
    puts v.visit(event, data)
  end
end

# Interpreter example.
rule = LengthRule.new(10)
puts "rule matches 'short'? #{rule.matches?("short")}"
puts "rule matches 'a-very-long-payload'? #{rule.matches?("a-very-long-payload")}"

# =============================================================================
# EXERCISE 1
#   Add a "composite validator" (all validators must pass).
# SOLUTION 1:
#   class CompositeValidator
#     include Validator
#     def initialize(@vs : Array(Validator)); end
#     def valid?(p); @vs.all?(&.valid?(p)); end
#   end
#   pipeline = TrimUpcasePipeline.new(
#     CompositeValidator.new([NonEmptyValidator.new, LengthValidator.new(20)] as Array(Validator)),
#     NullLogger.new
#   )
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a "Retry" decorator around a Step (retry on exception up to N times).
# SOLUTION 2:
#   class RetryStep < Step
#     def initialize(@inner : Step, @attempts = 3); end
#     def run(p)
#       t = 0
#       begin
#         t += 1
#         @inner.run(p)
#       rescue ex
#         raise ex if t >= @attempts
#         retry
#       end
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Identify which class demonstrates which behavioral pattern (map).
# SOLUTION 3:
#   - Strategy: Validator (NonEmpty, Length).
#   - State: Pending/Running/Completed/Failed.
#   - Command: Step (Trim, Upcase).
#   - Template Method: ProcessPipeline#run skeleton.
#   - Observer: Observer + ConsoleListener; EventBus (Mediator).
#   - Mediator: EventBus (publishers/subscribers decoupled).
#   - Memento: ProcessPipeline's @history snapshot for rollback.
#   - Iterator: HistoryIterator.
#   - Visitor: MarkdownVisitor / CsvVisitor.
#   - Interpreter: LengthRule (toy boolean language).
#   - Null Object: NullLogger.
#   - Chain of Responsibility: implied by "fallback validators" exercise 1
#     when composed; not the primary form here.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
