# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # ObjectInterface allows us to interact with external objects in a more standardized manner.
  # For example: configuration and objects passed into the module can be a little more liberal
  # in their specific types and key types.
  class ObjectInterface
    class << self
      def get(object, key)
        if object.is_a?(Hash)
          indifferent_hash_get(object, key)
        elsif object.respond_to?(key)
          object.send(key)
        end
      end

      private

      def indifferent_hash_get(hash, key)
        if hash.key?(key.to_s)
          hash[key.to_s]
        elsif hash.key?(key.to_s.to_sym)
          hash[key.to_s.to_sym]
        end
      end
    end
  end
end
