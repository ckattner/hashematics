# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A Type defines an object.
  class Type
    class << self
      def null_type
        @null_type ||= new
      end
    end

    HASH_VALUE = 'hash'
    OPEN_STRUCT_VALUE = 'open_struct'

    attr_reader :name, :object_class, :properties

    def initialize(name: '', properties: nil, object_class: nil)
      @name         = name
      @properties   = make_properties(properties)
      @object_class = object_class || HASH_VALUE

      freeze
    end

    def convert(object, child_hash = {})
      make_object(to_hash(object).merge(child_hash))
    end

    private

    def to_hash(object)
      (properties || default_properties(object)).map do |property, key|
        [property, ObjectInterface.get(object, key)]
      end.to_h
    end

    def default_properties(object)
      if object.respond_to?(:keys)
        make_properties(object.keys)
      else
        []
      end
    end

    def make_object(hash)
      if object_class.to_s == HASH_VALUE
        hash
      elsif object_class.to_s == OPEN_STRUCT_VALUE
        OpenStruct.new(hash)
      elsif object_class.is_a?(Proc)
        object_class.call(hash)
      else
        object_class.new(hash)
      end
    end

    def make_properties(val)
      if val.is_a?(Array) || val.is_a?(String) || val.is_a?(Symbol)
        Array(val).map { |v| [v, v] }.to_h
      else
        val
      end
    end
  end
end
