# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # Graph serves as the main point of entry for this system.
  # Basic use:
  # 1. Initialize a Graph by passing in an array of groups (tree structures)
  # 2. Feed in objects into the graph using the #add method
  # 3. Use the #groups, #records, and #objects methods to interact with the generated object graph.
  class Graph
    extend Forwardable

    attr_reader :group_dictionary, :record_set

    def_delegators :record_set, :rows

    def initialize(groups = [])
      @group_dictionary = Dictionary.new.add(groups, &:name)
      @record_set       = RecordSet.new

      freeze
    end

    def add(enumerable)
      enumerable.each { |object| add_one(object) }

      self
    end

    def children
      group_dictionary.map(&:name)
    end

    def visit(name)
      group(name)&.visit || []
    end

    def data(name)
      visit(name).map { |v| v.data(true) }
    end

    private

    def group(name)
      group_dictionary.get(name)
    end

    def add_one(object)
      record = record_set.add(object)

      group_dictionary.each do |group|
        group.add(record)
      end
    end
  end
end
