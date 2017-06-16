# Change Log

## master

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
