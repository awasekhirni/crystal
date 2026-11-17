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
#   A request enters the app: check authentication, log the URL, maybe
#   compress the response. Each layer passes the request along to the next.
#   If a layer rejects the request, it never reaches the next one.
#
# SETUP:
#   crystal run 067_chain_of_responsibility_middleware.cr
# =============================================================================

# --- Request and Response (simplified) -------------------------------------
class Request
  getter path : String, headers : Hash(String, String)
  def initialize(@path : String, @headers = {} of String => String); end
end

# Concrete class `Response`.
class Response
  getter status : Int32, body : String
  def initialize(@status : Int32, @body : String); end
  # Append this object's String representation to `io`.
  def to_s(io : IO) : Nil; io << "#{@status}: #{@body}"; end
end

# --- Middleware abstraction ------------------------------------------------
abstract class Middleware
  @next : Middleware?
  # Return the result of `chain`.
  def chain(next_mw : Middleware?) : Middleware?
    @next = next_mw
    next_mw
  end

  # Returns a Response. If this layer rejects, it returns a Response and
  # does NOT call @next.
  abstract def call(req : Request) : Response

  protected def call_next(req : Request) : Response?
    @next.try(&.call(req))
  end
end

# --- Concrete middleware --------------------------------------------------
class LoggingMiddleware < Middleware
  # Process `context` through this HTTP handler and call the next.
  def call(req : Request) : Response
    puts "[log] #{req.path}"
    call_next(req) || Response.new(404, "not found")
  end
end

# Concrete class `AuthMiddleware` -- extends Middleware.
class AuthMiddleware < Middleware
  # Process `context` through this HTTP handler and call the next.
  def call(req : Request) : Response
    unless req.headers["Authorization"]?.try(&.starts_with?("Bearer "))
      return Response.new(401, "unauthorized")
    end
    call_next(req) || Response.new(404, "not found")
  end
end

# Concrete class `RouterMiddleware` -- extends Middleware.
class RouterMiddleware < Middleware
  # Process `context` through this HTTP handler and call the next.
  def call(req : Request) : Response
    case req.path
    when "/hello" then Response.new(200, "hello!")
    else               call_next(req) || Response.new(404, "no route")
    end
  end
end

# --- Pipeline construction ------------------------------------------------
def build_pipeline : Middleware
  log = LoggingMiddleware.new
  auth = AuthMiddleware.new
  router = RouterMiddleware.new
  log.chain(auth).not_nil!.chain(router)
  log
end

# ---- Demonstration ----------------------------------------------------------
pipeline = build_pipeline

puts pipeline.call(Request.new("/hello", {"Authorization" => "Bearer xyz"}))
puts "---"
puts pipeline.call(Request.new("/hello"))                       # 401
puts "---"
puts pipeline.call(Request.new("/missing", {"Authorization" => "Bearer xyz"}))  # 404

# =============================================================================
# EXERCISE 1
#   Add a RateLimitMiddleware that returns 429 after N calls.
# SOLUTION 1:
#   class RateLimitMiddleware < Middleware
#     @count = 0
#     def initialize(@limit = 3); end
#     def call(req)
#       @count += 1
#       return Response.new(429, "too many") if @count > @limit
#       call_next(req) || Response.new(404, "not found")
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Post-process responses: add a header on the way back. Explain the diff.
# SOLUTION 2:
#   The pattern above "short-circuits" a request. Post-processing requires
#   wrapping the result: `resp = call_next(req); resp = transform(resp); resp`.
#   That shape is still CoR but with an on-unwind step, closer to Decorator.
#   Many real middlewares do both — log entry, forward, log exit.
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does each middleware define its own `@next` instead of a manager?
# SOLUTION 3:
#   Simplicity for short chains. For very long or dynamic chains, a central
#   `Pipeline` object (holding an Array(Middleware)) is cleaner — see 056.
#   The pattern doesn't mandate linked nodes; only the "handle or forward"
#   contract matters.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
