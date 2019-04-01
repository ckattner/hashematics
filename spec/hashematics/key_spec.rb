# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Hashematics::Key do
  describe '#eql?' do
    it 'should compare Key objects' do
      expect(described_class.new('id')).to eq(described_class.new('id'))
      expect(described_class.new('id')).to eq(described_class.new(:id))
      expect(described_class.new(['id'])).to eq(described_class.new('id'))
      expect(described_class.new([:id])).to eq(described_class.new('id'))
      expect(described_class.new([:id])).to eq(described_class.new(['id']))
    end

    it 'should compare Key with string' do
      expect(described_class.new('id')).to eq('id')
      expect(described_class.new(:id)).to eq('id')
    end

    it 'should compare Key with symbol' do
      expect(described_class.new('id')).to eq(:id)
      expect(described_class.new(:id)).to eq(:id)
    end

    it 'should compare Key with array' do
      expect(described_class.new('id')).to eq(['id'])
      expect(described_class.new(:id)).to eq([:id])
    end
  end
end
