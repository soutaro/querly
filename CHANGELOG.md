# Change Log

## master

## 1.2.0 (2020-12-15)

* Relax Thor version requirements by @y-yagi ([#85](https://github.com/soutaro/querly/pull/85))
* Fix ERB comment preprocessing by @mallowlabs ([#84](https://github.com/soutaro/querly/pull/84))
* Better error message for Ruby code syntax error by @ybiquitous ([#83](https://github.com/soutaro/querly/pull/83))

## 1.1.0 (2020-05-17)

* Fix invalid bytes sequence in UTF-8 error by @mallowlabs [#75](https://github.com/soutaro/querly/pull/75)
* Detect safe navigation operator as a method call by @pocke [#71](https://github.com/soutaro/querly/pull/71)

## 1.0.0 (2019-7-19)

* Add `--config` option for `find` and `console` [#67](https://github.com/soutaro/querly/pull/67)
* Improve preprocessor performance by processing concurrently [#68](https://github.com/soutaro/querly/pull/68)

## 0.16.0 (2019-04-23)

* Support string literal pattern (@pocke) [#64](https://github.com/soutaro/querly/pull/64)
* Allow underscore method name pattern (@pocke) [#63](https://github.com/soutaro/querly/pull/63)
* Add erb support (@hanachin) [#61](https://github.com/soutaro/querly/pull/61)
* Add `exit` command on console (@wata727) [#59](https://github.com/soutaro/querly/pull/59)

## 0.15.1 (2019-03-12)

* Relax parser version requirement

## 0.15.0 (2019-02-13)

* Fix broken `querly init` template (@ybiquitous) #56
* Relax `activesupport` requirement (@y-yagi) #57

## 0.14.0 (2019-01-22)

* Allow having `...` pattens anywhere positional argument patterns are valid #54
* Add `querly find` command (@gfx) #49

## 0.13.0 (2018-08-27)

* Make history file location configurable through `QUERLY_HOME` (defaults to `~/.querly`)
* Save `console` history (@gfx) #47

## 0.12.0 (2018-08-03)

* Declare MIT license #44
* Make reading backtrace easier in `console` command (@pocke) #43
* Highlight matched expression in querly console (@pocke) #42
* Set exit status = 1 when `querly.yaml` has syntax error (@pocke) #41
* Fix typos (@koic, @vzvu3k6k) #40, #39

## 0.11.0 (2018-04-22)

* Relax `rainbow` version requirement

## 0.10.0 (2018-04-13)

* Update parser (@yoshoku) #38
* Use Ruby25 parser

## 0.9.0 (2018-03-02)

* Fix literal testing (@pocke) #37

## 0.8.4 (2018-02-11)

* Loosen the restriction of `thor` version (@shinnn) #36

## 0.8.3 (2018-01-16)

* Fix preprocessor to avoid deadlocking #35

## 0.8.2 (2018-01-13)

* Move `Concerns::BacktraceFormatter` under `Querly`  (@kohtaro24) #34

## 0.8.1 (2017-12-22)

* Update dependencies

## 0.8.0 (2017-12-19)

* Make `[conditional]` be aware of safe-navigation-operator (@pocke) #30
* Make preprocessors be aware of `bundle exec`.
  When `querly` is invoked with `bundle exec`, so are preprocessors, and vice vesa.
* Add `--rule` option for `querly check` to filter rules to test
* Print rule id in text output

## 0.7.0 (2017-08-22)

* Add Wiki pages to repository in manual directory #25
* Add named literal pattern `:string: as 'name` with `where: { name: ["alice", /bob/] }` #24
* Add `init` command #28

## 0.6.0 (2017-06-27)

* Load current directory when no path is given (@wata727) #18
* Require Active Support ~> 5.0 (@gfx) #17
* Print error message if HAML 5.0 is loaded (@pocke) #16

## 0.5.0 (2017-06-16)

* Exit 1 on test failure #9
* Fix example index printing in test (@pocke) #8, #10
* Introduce pattern matching on method name by set of string and regexp
* Rule definitions in config can have more structured `examples` attribute

## 0.4.0 (2017-05-25)

* Update `parser` to 2.4 compatible version
* Check more pathnames which looks like Ruby by default (@pocke) #7

## 0.3.1 (2017-02-16)

* Allow `require` rules from config file
* Add `version` command
* Fix *with block* and *without block* pattern parsing
* Prettier backtrace printing
* Prettier pattern syntax error message

## 0.2.1 (2016-11-24)

* Fix `self` pattern matching

## 0.2.0 (2016-11-24)

* Remove `tagging` section from config
* Add `check` section to select rules to check
* Add `import` section to load rules from other file
* Add `querly rules` sub command to print loaded rules
* Add *with block* and *without block* pattern (`foo() {}` / `foo() !{}`)
* Add *some of receiver chain* pattern (`...`)
* Fix keyword args pattern matching bug

## 0.1.0

* First release.
