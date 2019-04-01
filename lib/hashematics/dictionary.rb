# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A Dictionary is an array with a constant O(1) lookup time.  It is basically a cross of a hash
  # and an array.  We could easily use a hashes everywhere, but explicitly coding our intentions
  # of this common intra-library hash use is a nice way to communicate intentions while minimizing
  # duplication.
  class Dictionary
    extend Forwardable

    attr_reader :default_value

    def_delegators :lookup, :keys

    def_delegator :lookup, :values, :all

    def initialize(default_value = nil)
      @default_value = default_value
      @lookup = {}

      freeze
    end

    def add(enumerable)
      raise ArgumentError, 'block must be given for key resolution' unless block_given?

      enumerable.each do |entry|
        key = yield entry
        set(key, entry)
      end

      self
    end

    def set(key, object)
      lookup[key.to_s] = object

      self
    end

    def get(key)
      exist?(key) ? lookup[key.to_s] : default_value
    end

    def exist?(key)
      lookup.key?(key.to_s)
    end

    def each
      return enum_for(:each) unless block_given?

      all.each { |o| yield o }
    end

    def map(&block)
      return enum_for(:map) unless block_given?

      all.map(&block)
    end

    private

    attr_reader :lookup
  end
end
