# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # This class understands how to take in a hash of options and construct an array of groups.
  # See test fixtures for examples.
  class Configuration
    module Keys
      BY                = :by
      GROUPS            = :groups
      INCLUDE_BLANK     = :include_blank
      OBJECT_CLASS      = :object_class
      PROPERTIES        = :properties
      TYPE              = :type
      TYPES             = :types
    end
    include Keys

    attr_reader :groups

    def initialize(config = {})
      types = build_types(config_value(config, TYPES))
      @type_dictionary = Dictionary.new(Type.null_type).add(types, &:name)

      @groups = build_groups(config_value(config, GROUPS))

      freeze
    end

    private

    attr_reader :type_dictionary

    def build_types(type_config = {})
      (type_config || {}).map do |name, options|
        properties = config_value(options, PROPERTIES)
        object_class = config_value(options, OBJECT_CLASS)

        Type.new(name: name, properties: properties, object_class: object_class)
      end
    end

    def build_groups(group_config = {}, parent_key_parts = [])
      (group_config || {}).map do |name, options|
        id_key_parts = make_id_key_parts(options)

        category = Category.new(
          id_key: id_key_parts,
          include_blank: include_blank?(options),
          parent_key: parent_key_parts
        )

        Group.new(
          category: category,
          children: make_children(options, parent_key_parts + id_key_parts),
          name: name,
          type: make_type(options)
        )
      end
    end

    def include_blank?(options)
      options.is_a?(Hash) ? config_value(options, INCLUDE_BLANK) : false
    end

    def make_id_key_parts(options)
      options.is_a?(Hash) ? Array(config_value(options, BY)) : Array(options)
    end

    def make_children(options, parent_key_parts)
      options.is_a?(Hash) ? build_groups(config_value(options, GROUPS), parent_key_parts) : []
    end

    def make_type(options)
      type_name = options.is_a?(Hash) ? config_value(options, TYPE) : nil

      type_dictionary.get(type_name)
    end

    def config_value(config, key)
      ObjectInterface.get(config, key)
    end
  end
end
