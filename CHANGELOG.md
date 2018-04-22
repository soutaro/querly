# Change Log

## master

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
