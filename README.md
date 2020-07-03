![Querly logo](https://github.com/soutaro/querly/blob/master/logo/Querly%20horizontal.png)

# Querly - Pattern Based Checking Tool for Ruby

![Ruby](https://github.com/soutaro/querly/workflows/Ruby/badge.svg)

Querly is a query language and tool to find out method calls from Ruby programs.
Define rules to check your program with patterns to find out *bad* pieces.
Querly finds out matching pieces from your program.

## Overview

Your project may have many local rules:

* Should not use `Customer#update_mail` and use 30x faster `Customer.update_all_email` instead (Slower `#update_mail` is left just for existing code, but new code should not use it)
* Should not use `root_url` without `locale:` parameter
* Should not use `Net::HTTP` for Web API calls, but use `HTTPClient`

These local rule violations will be found during code review.
Reviewers will ask commiter to revise; commiter will fix; fine.
Really?
It is boring and time-consuming.
We need some automation!

However, that rules cannot be the standard.
They make sense only in your project.
Okay, start writing a plug-in for RuboCop? (or other checking tools)

Instead of writing RuboCop plug-in, just define a Querly rule in a few lines of YAML.

```yml
rules:
  - id: my_project.use_faster_email_update
    pattern: update_mail
    message: When updating Customer#email, newly written code should use 30x faster Customer.update_all_email
    justification:
      - When you are editing old code (it should be refactored...)
      - You are sure updating only small number of customers, and performance does not matter

  - id: my_project.root_url_without_locale
    pattern: "root_url(!locale: _)"
    message: Links to top page should be with locale parameter

  - id: my_project.net_http
    pattern: Net::HTTP
    message: Use HTTPClient to make HTTP request
```

Write down your local rules, and let Querly check conformance with them.
Focus on spec, design, UX, and other important things during code review!

## Installation

Install via RubyGems.

    $ gem install querly

Or you can put it in your Gemfile.

```rb
gem 'querly'
```

## Quick Start

Copy the following YAML and paste as `querly.yml` in your project's repo.

```yaml
rules:
  - id: sample.debug_print
    pattern:
      - self.p
      - self.pp
    message: Delete debug print
```

Run `querly` in the repo.

```
$ querly check .
```

If your code contains `p` or `pp` calls, querly will print warning messages.

```
./app/models/account.rb:44:10                  p(account.id)      Delete debug print
./app/controllers/accounts_controller.rb:17:2  pp params: params  Delete debug print
```

## Configuration

See the following manual for configuration and query language reference.

* [Configuration](https://github.com/soutaro/querly/blob/master/manual/configuration.md)
* [Patterns](https://github.com/soutaro/querly/blob/master/manual/patterns.md)

Use `querly console` command to test patterns interactively.

## Requiring Rules

`import` section in config file now allows accepts `require` command.

```yaml
import:
  - require: querly/rules/sample
  - require: your_library/querly/rules
```

Querly ships with `querly/rules/sample` rule set. Check `lib/querly/rules/sample.rb` and `rules/sample.yml` for detail.

### Publishing Gems with Querly Rules

Querly provides `Querly.load_rule` API to allow publishing your rules as part of Ruby library.
Put rules YAML file in your gem, and add Ruby script in some directory like `lib/your_library/querly/rules.rb`.

```
Querly.load_rules File.join(__dir__, relative_path_to_yaml_file)
```

## Notes

### Querly's analysis is syntactic

The analysis is currently purely syntactic:

```rb
record.save(validate: false)
```

and

```rb
x = false
record.save(validate: x)
```

will yield different results.
This can be improved by doing very primitive data flow analysis, and I'm planning to do that.

### Too many false positives!

The analysis itself does not have very good precision.
There will be many false positives, and *querly warning free code* does not make much sense.

* TODO: support to ignore warnings through magic comments in code

Querly is not to ensure *there is nothing wrong in the code*, but just tells you *code fragments you should review with special care*.
I believe it still improves your software development productivity.

### Incoming updates?

The following is the list of updates which would make sense.

* Support for importing rule sets, and provide some good default rules
* Support for ignoring warnings
* Improve analysis precision by intra procedural data flow analysis

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soutaro/querly.

