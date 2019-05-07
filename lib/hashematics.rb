# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'digest'
require 'forwardable'
require 'objectable'
require 'ostruct'

require_relative 'hashematics/category'
require_relative 'hashematics/configuration'
require_relative 'hashematics/dictionary'
require_relative 'hashematics/graph'
require_relative 'hashematics/group'
require_relative 'hashematics/key'
require_relative 'hashematics/id'
require_relative 'hashematics/object_interface'
require_relative 'hashematics/record'
require_relative 'hashematics/record_set'
require_relative 'hashematics/type'
require_relative 'hashematics/visitor'

# Top-level API syntactic sugar that holds the common library use(s).
module Hashematics
  class << self
    def graph(config: {}, rows: [])
      groups = Configuration.new(config).groups

      Graph.new(groups).add(rows)
    end
  end
end
