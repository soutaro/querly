# Overview

The configuration file, default name is `querly.yml`, will look like the following.

```yml
rules:
  ...
preprocessor:
  ...
check:
  ...
```

# rules

`rules` is array of rule hash.

```yml
  - id: com.sideci.json
    pattern: Net::HTTP
    message: "Should use HTTPClient instead of Net::HTTP"
    justification:
      - No exception!
    before:
      - "Net::HTTP.get(url)"
    after:
      - HTTPClient.new.get_content(url)
```

The rule hash contains following keys:

* `id` Identifier of the rule, must be unique (string)
* `pattern` Patterns to find out (string, or array of string)
* `message` Error message to explain why the code fragment needs special care (string)
* `justification` When the *bad use* is allowed (string, or array of string)
* `before` Sample ruby code to find out (string, or array of string)
* `after` Sample ruby code to be fixed (string, or array of string)

# preprocessor

When your project contains `.slim`, `.haml`, or any templates which contains Ruby code, preprocessor is to translate the templates to Ruby code.
`preprocessor` is a hash; key of extension of the templates, value of command line.

```yml
.slim: slimrb --compile
.haml: bundle exec querly-pp haml -I lib -r your_custom_plugin
```

The command will be executed with stdin of template code, and should emit ruby code to stdout.

## querly-pp

Querly 0.2.0 ships with `querly-pp` command line tool which compiles given HAML source to Ruby script.
`-I` and `-r` options can be used to use plugins.

# check

Define set of rules to check for each file.

```yml
check:
  - path: /test
    rules:
      - com.acme.corp
      - append: com.acme.corp
      - except: com.acme.corp
      - only: com.acme.corp
  - path: /test/unit
    rules:
      - append:
          tags: foo bar
      - except:
          tags: foo bar
      - only:
          tags: foo bar
```

* `path` Files to apply the rules in `.gitignore` syntax
* `rules` Rules to check

All matching `check` element against given file name will be applied, sequentially.

* `/lib/bar.rb` => no checks will be applied (all rules)
* `/test/test_helper.rb` => `/test` check will be applied
* `/test/unit/account_test.rb` => `/test` and `/test/unit` checks will be applied

## Rules

You can use `append:`, `except:` and `only:` operation.

* `append:` appends rules to current rule set
* `except:` removes rules from current rule set
* `only:` update current rule set

