require 'pathname'
require "yaml"
require "rainbow"
require "parser/current"
require "set"
require "open3"

Parser::Builders::Default.emit_lambda = true

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
require "querly/tagging"
require "querly/preprocessor"

require "querly/loader/ruby"
require "querly/loader/haml"
require "querly/loader/slim"

module Querly
  # Your code goes here...
end
