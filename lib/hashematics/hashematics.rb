# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'digest'
require 'forwardable'
require 'ostruct'

require_relative 'category'
require_relative 'configuration'
require_relative 'dictionary'
require_relative 'graph'
require_relative 'group'
require_relative 'key'
require_relative 'id'
require_relative 'object_interface'
require_relative 'record'
require_relative 'record_set'
require_relative 'type'
require_relative 'visitor'

# Top-level API syntactic sugar that holds the common library use(s).
module Hashematics
  class << self
    def graph(config: {}, rows: [])
      groups = ::Hashematics::Configuration.new(config).groups

      ::Hashematics::Graph.new(groups).add(rows)
    end
  end
end
