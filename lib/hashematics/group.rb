# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A group is a node in a tree structure connected to other groups through the children
  # attribute.  A group essentially represents an object within the object graph and its:
  # 1. Category (index) for the parent to use as a lookup
  # 2. Type that describes the object properties, field mapping, etc.
  class Group
    attr_reader :category, :name, :type

    def initialize(category:, children:, name:, type:)
      @category         = category
      @child_dictionary = Dictionary.new.add(children, &:name)
      @name             = name
      @type             = type

      freeze
    end

    def add(record)
      category.add(record)

      child_dictionary.each { |c| c.add(record) }

      self
    end

    def children
      child_dictionary.map(&:name)
    end

    def visit(parent_record = nil)
      category.records(parent_record).map do |record|
        Visitor.new(group: self, record: record)
      end
    end

    def visit_children(name, parent_record = nil)
      child_group(name)&.visit(parent_record) || []
    end

    private

    attr_reader :child_dictionary

    def child_group(group_name)
      child_dictionary.get(group_name)
    end
  end
end
