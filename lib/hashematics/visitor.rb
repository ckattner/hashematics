# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A Visitor is a Record found in the context of a Group.  When traversing the object
  # graph (group tree), it will provide these Visitor objects instead of Record objects
  # that allows you to view the Record in the context of the graph, while a Record is more of just
  # the raw payload provided by the initial flat data set.
  class Visitor
    extend Forwardable

    def_delegators :group, :children, :type

    attr_reader :group, :record

    def initialize(group:, record:)
      @group  = group
      @record = record

      freeze
    end

    def data(include_children = false)
      child_hash = include_children ? make_child_hash : {}

      type.convert(record.data, child_hash)
    end

    def visit(name)
      group.visit_children(name, record)
    end

    private

    def make_child_hash
      children.map do |name|
        [
          name,
          visit(name).map { |v| v.data(true) }
        ]
      end.to_h
    end
  end
end
