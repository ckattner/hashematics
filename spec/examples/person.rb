# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class Person
  attr_accessor :dob, :first, :id, :last, :smoker

  def initialize(attrs = {})
    attrs.each do |k, v|
      send("#{k}=", v) if respond_to?(k)
    end
  end

  def eql?(other)
    to_hash == other.to_hash
  end

  def ==(other)
    eql?(other)
  end

  def to_hash
    {
      id: id,
      first: first,
      last: last,
      smoker: smoker,
      dob: dob
    }
  end
end
