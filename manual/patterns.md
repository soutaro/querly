# Syntax

## Toplevel

* *expr*
* *expr* `[` *kind* `]` (kinded expr)
* *expr* `[!` *kind* `]` (negated kinded expr)

## expr

* `_` (any expr)
* *method* (method call, with any receiver and any args)
* *method* `(` *args* `)` *block_spec* (method call with any receiver)
* *receiver* *method* (method call with any args)
* *receiver* *method* `(` *args* `)` *block_spec* (method call)
* *literal*
* `self` (self)
* `!` *expr*

### block_spec

* (no spec)
* `{}` (method call should be with block)
* `!{}` (method call should not be with block)

### receiver

* *expr* `.` (receiver matching with the pattern)
* *expr* `...` (some receiver in the chain matching with the pattern)

### Examples

* `p(_)` `p` call with one argument, any receiver
* `self.p(1)` `p` call with `1`, receiver is `self` or omitted.
* `foo.bar.baz` `baz` call with receiver of `bar` call of receiver of `foo` call
* `update_attribute(:symbol:, :string:)` `update_attribute` call with symbol and string literals
* `File.open(...) !{}` `File.open` call but without block

```rb
p 1        # p(_) matches
p 2        # p(_) matches
p 1, 2, 3  # p(_) does not match

p(1)       # self.p(1) matches

foo(1).bar {|x| x+1 }.baz(3)  # foo.bar.baz matches
(1+2).foo.bar(*args).baz.bla  # foo.bar.baz matches, partially
foo.xyz.bar.baz               # foo.bar.baz does not match

update_attribute(:name, "hoge")    # f(:symbol:, :string:) matches
update_attribute(:name, name)      # f(:symbol:, :string:) does not match

foo.bar.baz               # foo.bar.baz matches
foo.bar.baz               # foo...baz matches
bar.foo.baz               # foo...bar...baz does not match
```

## args & kwargs

### args

* *expr* `,` *args*
* *expr* `,` *kwargs*
* *expr*
* `...` `,` *kwargs* (any argument sequence, followed by keyword arguments)
* `...` (any argument sequence, including any keyword arguments)

### Literals

* `123` (integer)
* `1.23` (float)
* `:foobar` (symbol)
* `:symbol:` (any symbol literal)
* `:string:` (any string literal)
* `:dstr:` (any dstr `"hi #{name}"`)
* `true`, `false` (true and false)
* `nil` (nil)
* `:number:`, `:int:`, `:float:` (any number, any integer, any float)
* `:bool:` (true or false)

### kwargs

* *symbol* `:` *expr* `,` ...
* `!` *symbol* `:` *expr* `,` ...
* `...`
* `&` *expr*

### Examples

```rb
f(1,2,3)   # f(...), f(1,2,...), and f(1, ...) matches
           # f(_,_), f(0, ...) does not match

JSON.load(string, symbolize_names: true)   # JSON.load(..., symbolize_names: true) matches
                                           # JSON.load(symbolize_names: true) does not match

record.update(email: email, name: name)    # update(name: _, email: _) matches
                                           # update(name: _) does not match
                                           # update(name: _, ...) matches
                                           # update(!id: _, ...) matches

article.try(&:author)        # try(&:symbol:) matches
article.try(:author)         # try(&:symbol:) does not match
article.try {|x| x.author }  # try(&:symbol:) does not match
```

## kind

* `conditional` (When expr appears in *conditional* context)
* `discarded` (When expr appears in *discarded* context)

Kind allows you to find out something like:

* `save` call but does not check its result for error recovery

*conditional* context is

* Condition of `if` construct
* Condition of loop constructs
* LHS of `&&` and `||`

```rb
# record.save is in conditional context
unless record.save
  # error recovery
end

# record.save is not in conditional context
x = record.save

# record.save is in conditional context
record.save or abort()
```

*discarded* context is where the value of the expression is completely discarded, a bit looser than *conditional*.

```rb
def f()
  # record.save is in discarded context
  foo()
  record.save()
  bar
end
```

# Difference from Ruby

* Method call parenthesis cannot be omitted (if omitted, it means *any arguments*)
* `+`, `-`, `[]` or other *operator* should be written as method calls like `_.+(_)`, `[]=(:string:, _)`

# Testing

You can test patterns by `querly console .` command interactively.

```
Querly 0.1.0, interactive console

Commands:
  - find PATTERN   Find PATTERN from given paths
  - reload!        Reload program from paths
  - quit

Loading... ready!
> 
```

Also `querly test` will help you.
It test configuration file by checking patterns in rules against `before` and `after` examples.
