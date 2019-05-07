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
        resolver.get(object, key)
      end

      private

      def resolver
        @resolver ||= Objectable.resolver(separator: nil)
      end
    end
  end
end
