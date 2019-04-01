# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Hashematics
  # An ID is just like a Key except its value is digested (hashed).  The main rationale for this
  # is ID's also contains user data, which could be unbound data, which could potentially
  # consume lots of memory.  To limit this, we digest it.
  class Id < Key
    class << self
      # This method is class-level to expose the underlying hashing algorithm used.
      def digest(val = '')
        # MD5 was chosen for its speed, it was not chosen for security.
        Digest::MD5.hexdigest(val)
      end
    end

    private

    def make_value
      self.class.digest(parts.map(&:to_s).join(SEPARATOR))
    end
  end
end
