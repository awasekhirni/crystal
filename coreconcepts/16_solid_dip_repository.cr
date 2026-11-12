# Copyright 2026 Beta ORI Inc. All Rights Reserved.
# Syed, Awase Khirni
#
# Installation Instructions
# https://crystal-lang.org/install/
# https://zed.dev/extensions/crystal - add this extension to your zed editor
# build : crystal build 001
# run : crystal run
#
# ELIM5: Dependency Injection Principle. In this example we are looking at data access. business logic depends on a
# repository interface, not on SQL or files. A shop assistant does not care whether stock is in a warehouse or in a
# a corner shop. they are concerned only if the specific item X is available. "do we have item X?"
# =============================================================================



# Domain entity.
class User
  getter id : Int32, name : String
  def initialize(@id : Int32, @name : String); end
  def to_s(io : IO) : Nil; io << "User(#{@id}, #{@name})"; end
end

# Abstraction the business layer depends on.
module UserRepository
  abstract def find(id : Int32) : User?
  abstract def save(user : User) : Nil
end

# Concrete adapter #1: in-memory.
class InMemoryUserRepository
  include UserRepository
  @store = {} of Int32 => User
  def find(id : Int32) : User?; @store[id]?; end
  def save(user : User) : Nil; @store[user.id] = user; end
end

# Concrete adapter #2: "log" repo (simulates a different backend).
class LoggingUserRepository
  include UserRepository
  @store = {} of Int32 => User
  def find(id : Int32) : User?
    puts "[repo] find(#{id})"
    @store[id]?
  end
  def save(user : User) : Nil
    puts "[repo] save #{user}"
    @store[user.id] = user
  end
end

# Business logic: only depends on the abstraction.
class UserService
  def initialize(@repo : UserRepository); end
  def register(id : Int32, name : String) : User
    u = User.new(id, name)
    @repo.save(u)
    u
  end
  def lookup(id : Int32) : User?
    @repo.find(id)
  end
end

# ----Execution-------------------------------------------
svc = UserService.new(InMemoryUserRepository.new)
svc.register(1, "Syed Awase Khirni ")
puts svc.lookup(1)

svc2 = UserService.new(LoggingUserRepository.new)
svc2.register(2, "Syed Ameese Sadath")
puts svc2.lookup(2)

svc3 = UserService.new(LoggingUserRepository.new)
svc3.register(3, "Syed Azeez Al-Asaad")
puts svc3.lookup(3)

# =============================================================================
# EXERCISE 1
#   Add a FileUserRepository that reads/writes "id:name" lines to a file.
# SOLUTION 1:
#   class FileUserRepository
#     include UserRepository
#     def initialize(@path : String); end
#     def find(id : Int32) : User?
#       return nil unless File.exists?(@path)
#       File.each_line(@path) do |line|
#         i, n = line.split(":", 2)
#         return User.new(i.to_i, n) if i.to_i == id
#       end
#       nil
#     end
#     def save(user : User) : Nil
#       File.open(@path, "a") { |f| f.puts "#{user.id}:#{user.name}" }
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 2
#   Add a CachingUserRepository that wraps another repo and memoizes reads.
# SOLUTION 2:
#   class CachingUserRepository
#     include UserRepository
#     def initialize(@inner : UserRepository); @cache = {} of Int32 => User; end
#     def find(id : Int32) : User?
#       @cache[id]? || (@inner.find(id).tap { |u| @cache[id] = u if u })
#     end
#     def save(user : User) : Nil
#       @inner.save(user)
#       @cache[user.id] = user
#     end
#   end
# =============================================================================

# =============================================================================
# EXERCISE 3
#   Add a UserService method that lists all users, without changing
#   UserRepository — and explain why that's tricky under strict DIP.
# SOLUTION 3:
#   Option A: extend the interface (allowed: add `all : Array(User)`).
#   Option B: introduce a separate query interface `UserQueryable` and
#   implement it selectively (ISP-friendly). Option B avoids bloating
#   write-only repositories with read methods they don't support.
# =============================================================================
