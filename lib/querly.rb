require 'pathname'
require 'parser/current'
require "yaml"

require "querly/version"
require 'querly/analyzer'
require 'querly/rule'
require 'querly/pattern/expr'
require 'querly/pattern/argument'
require 'querly/script'
require 'querly/script_enumerator'
require 'querly/node_pair'
require "querly/pattern/parser"
require "querly/config"

Parser::Builders::Default.emit_lambda = true

module Querly
  # Your code goes here...
end
