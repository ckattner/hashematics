# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A Key is a unique identifier and can be used for hash keys, comparison, etc.
  # Essentially it is a joined and hashed list of strings.
  class Key
    extend Forwardable

    class << self
      # This class-level method allows for the caching/memoization of Key objects already
      # allocated.  Since Key objects will have such a high instantiation count with
      # the potential of a lof of re-use, it makes sense to try to be a bit more
      # memory-optimized here.
      def get(parts = [])
        return parts if parts.is_a?(self)

        keys[parts] ||= new(parts)
      end
      alias default get

      private

      def keys
        @keys ||= {}
      end
    end

    SEPARATOR = '::'

    private_constant :SEPARATOR

    def_delegators :parts, :each_with_object, :map, :any?

    attr_reader :parts, :value

    def initialize(parts = [])
      @parts = Array(parts)
      @value = make_value

      freeze
    end

    # We can compare a Key object to a non-Key object since its constructor is rather pliable.
    # This means we can do things like this:
    # - Key.make(['id', :name]) == ['id', 'name']
    # - Key.make(:id) == 'id'
    # - Key.make(['id']) == :id
    # Those are all equivalent and should return true.
    def eql?(other)
      return eql?(self.class.get(other)) unless other.is_a?(self.class)

      value == other.value
    end

    def ==(other)
      eql?(other)
    end

    def hash
      value.hash
    end

    private

    def make_value
      parts.map(&:to_s).join(SEPARATOR)
    end
  end
end
