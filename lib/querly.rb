require 'pathname'
require "yaml"
require "rainbow"
require "parser/current"
require "set"
require "open3"
require "active_support/inflector"

require "querly/version"
require 'querly/analyzer'
require 'querly/rule'
require 'querly/pattern/expr'
require 'querly/pattern/argument'
require 'querly/script'
require 'querly/script_enumerator'
require 'querly/node_pair'
require "querly/pattern/parser"
require 'querly/pattern/kind'
require "querly/config"
require "querly/preprocessor"
require "querly/check"
require "querly/concerns/backtrace_formatter"

module Querly
  @@required_rules = []

  def self.required_rules
    @@required_rules
  end

  def self.load_rule(*files)
    files.each do |file|
      path = Pathname(file)
      yaml = YAML.load(path.read)
      rules = yaml.map {|hash| Rule.load(hash) }
      required_rules.concat rules
    end
  end
end
