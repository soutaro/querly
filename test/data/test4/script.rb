array = [1, 2, 3]

# Endless range since Ruby 2.6
array[1..]

# Beginless range since Ruby 2.7
array[..1]

# Numbered block parameters since Ruby 2.7
array.map { _1**2 }

# Pattern matching since Ruby 2.7
case array
in [a, *]
  puts a
end

# Arguments forwarding since Ruby 2.7
def foo(...)
  bar(...)
end

# Extended arguments forwarding since Ruby 3.0
def foo2(a, ...)
  bar2(a, ...)
end

# One-line pattern matching since Ruby 3.0
{ a: 1, b: 2, c: 3 } => hash

# Endless method definition since Ruby 3.0
def square(x) = x * x
