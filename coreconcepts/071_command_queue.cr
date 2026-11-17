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
#   In an office, you don't run errands as they arrive; you put each on a
#   to-do list. Later, a worker works through the list. Command objects can
#   be stored in a queue, sorted, retried, or serialized.
#
# SETUP:
#   crystal run 071_command_queue.cr
# =============================================================================

# --- Command with metadata -------------------------------------------------
abstract class Job
  getter id : String, payload : String
  def initialize(@id : String, @payload : String); end
  # Return the result of `perform`.
  abstract def perform : String

  # Optional hooks: jobs can implement these or ignore them.
  def on_success : Nil; end
  # Callback for the `failure` event.
  def on_failure(ex : Exception) : Nil; end
end

# Concrete class `SendEmailJob` -- extends Job.
class SendEmailJob < Job
  # Return the result of `perform`.
  def perform : String
    raise "simulated failure" if @payload.includes?("fail")
    "sent email to #{@payload}"
  end
end

# Concrete class `GenerateReportJob` -- extends Job.
class GenerateReportJob < Job
  # Return the result of `perform`.
  def perform : String; "generated report '#{@payload}'"; end
end

# --- Queue with retry ------------------------------------------------------
class JobQueue
  def initialize; end
  @pending = [] of Job
  @done = [] of String
  @failed = [] of Tuple(Job, String)

  # Return the result of `enqueue`.
  def enqueue(job : Job) : Nil; @pending << job; end

  # Process all queued jobs, retrying up to 2 times.
  def process_all : Nil
    while job = @pending.shift?
      attempts = 0
      begin
        attempts += 1
        result = job.perform
        job.on_success
        @done << "#{job.id}: #{result}"
      rescue ex
        if attempts < 2
          @pending << job  # requeue at end
        else
          job.on_failure(ex)
          @failed << {job, ex.message.to_s}
        end
      end
    end
  end

  # Return the result of `done`.
  def done : Array(String); @done; end
  # Return the result of `failed`.
  def failed : Array(Tuple(Job, String)); @failed; end
end

# ---- Demonstration ----------------------------------------------------------
q = JobQueue.new
q.enqueue(SendEmailJob.new("1", "a@example.com"))
q.enqueue(SendEmailJob.new("2", "fail@example.com"))
q.enqueue(GenerateReportJob.new("3", "Q1"))
q.process_all

puts "Done:"
q.done.each { |line| puts "  #{line}" }
puts "Failed:"
q.failed.each { |(job, reason)| puts "  #{job.id}: #{reason}" }

# =============================================================================
# EXERCISE 1
#   Add a DelayJob that records when it ran (simulate by printing time).
# SOLUTION 1:
#   class DelayJob < Job
#     def perform; "ran at #{Time.utc}"; end
#   end
#   q.enqueue(DelayJob.new("4", "later"))
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add priority so urgent jobs run first (PriorityQueue-lite).
# SOLUTION 2:
#   Add `priority : Int32 = 0` to Job; before `shift?`, sort @pending by
#   priority desc: `@pending.sort_by! { |j| -j.priority }`. For high volumes
#   use Crystal's `PriorityQueue`-like structures or a heap.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Discuss persistence: how would you survive a crash mid-queue?
# SOLUTION 3:
#   Persist each enqueued job to a durable store (DB/file) before execution,
#   mark completion/failure after. On startup, replay "pending" jobs. This
#   is the basis of durable job systems (Sidekiq, etc.).
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
