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
#   The reception desk at a hotel lets you order room service from your
#   phone. You're not calling the kitchen directly — the reception relays
#   your request. A remote proxy stands in for an object in another
#   process/machine and forwards calls over the network.
#
# SETUP:
#   crystal run 064_proxy_remote.cr
# =============================================================================

# Module `WeatherService`.
module WeatherService
  # Return the result of `temperature`.
  abstract def temperature(city : String) : Float64
end

# "Remote" service — imagine this on another host.
class RemoteWeatherService
  include WeatherService
  # Return the result of `temperature`.
  def temperature(city : String) : Float64
    # Simulates the remote object being far away.
    22.5
  end
end

# Remote proxy: handles connection setup, retries, and serialization.
# Here we simulate the network with a delay and a counter.
class WeatherRemoteProxy
  include WeatherService
  @calls = 0

  def initialize(@endpoint : String = "tcp://weather"); end

  # Return the result of `temperature`.
  def temperature(city : String) : Float64
    @calls += 1
    puts "[proxy] connecting to #{@endpoint}"
    sleep 0.05  # simulate network
    # In a real implementation, serialize "temperature(city)" and send it.
    RemoteWeatherService.new.temperature(city)
  end

  # Return the result of `call_count`.
  def call_count : Int32
    @calls
  end
end

# ---- Demonstration ----------------------------------------------------------
svc : WeatherService = WeatherRemoteProxy.new("tcp://weather.internal:7000")
puts svc.temperature("Oslo")
puts svc.temperature("Bergen")

# =============================================================================
# EXERCISE 1
#   Add caching in the proxy so repeated calls to the same city are cheap.
# SOLUTION 1:
#   @cache = {} of String => Float64
#   def temperature(city)
#     @cache[city]? || (@cache[city] = remote_call(city))
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add exponential backoff on failure.
# SOLUTION 2:
#   def temperature(city)
#     attempts = 0
#     begin
#       attempts += 1
#       remote_call(city)
#     rescue ex
#       raise ex if attempts >= 3
#       sleep(0.1  2  attempts)
#       retry
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Why does the proxy implement the same interface rather than expose a
#   distinct "client" API?
# SOLUTION 3:
#   Transparency: callers don't need to know if the service is local or
#   remote. That lets you start local (fast iteration), swap to remote in
#   production, and use remote in tests. Same-interface proxies are the
#   essence of Proxy; a different client API would be an Adapter or a Facade.
# =============================================================================

# =============================================================================
# ENHANCEMENTS SUGGESTED (added during code review)
#   The following improvements are recommended but not yet applied:
#
#   1. Add spec-style unit tests under `spec/` that exercise every public method (`crystal spec`).
#   2. Use `record(...)` or `struct` instead of `class` for value-like types to get value semantics for free.
#   3. Replace hand-rolled `inspect`/`to_s` overrides with `def_equals_and_hash` where equality is by value.
# =============================================================================
