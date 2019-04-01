# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # A Record object is composed of an inner object (most likely a hash) and provides extra
  # methods for the library.
  class Record
    extend Forwardable

    def_delegators :data, :keys, :hash

    attr_reader :data

    def initialize(data = {})
      @data = data

      freeze
    end

    def id?(key)
      Key.get(key).any? { |p| data[p].to_s.length.positive? }
    end

    def id(key)
      Id.get(id_parts(key))
    end

    def [](key)
      ObjectInterface.get(data, key)
    end

    # This should allow for Record objects to be compared to:
    # - Other Record objects
    # - Other data payload objects (most likely Hash objects)
    def eql?(other)
      return eql?(self.class.new(other)) unless other.is_a?(self.class)

      data == other.data
    end

    def ==(other)
      eql?(other)
    end

    private

    def id_parts(key)
      Key.get(key).each_with_object([]) do |p, arr|
        arr << p
        arr << data[p]
      end
    end
  end
end
