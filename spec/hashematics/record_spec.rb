# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Hashematics::Record do
  let(:csv_rows) { csv_fixture('data.csv') }

  describe '#category_id' do
    it 'returns correct ID for specified keys' do
      records = csv_rows.map { |row| described_class.new(row) }

      keys = [
        'ID #',
        ['ID #', 'Car ID #'],
        ['ID #', 'House ID #']
      ].map { |p| ::Hashematics::Key.new(p) }

      keys.each do |key|
        records.each do |record|
          concat_only = key.map { |p| "#{p}::#{record[p]}" }.join('::')
          expected_id_value = ::Hashematics::Id.digest(concat_only)

          actual_id_value = record.id(key).value

          expect(actual_id_value).to eq(expected_id_value)
        end
      end
    end
  end

  describe '#eql?' do
    it 'should compare Record objects' do
      expect(described_class.new(id: 1)).to eq(described_class.new(id: 1))
      expect(described_class.new(id: 1)).not_to eq(described_class.new(id: '1'))
    end

    it 'should compare Record to Hash objects' do
      expect(described_class.new(id: 1)).to eq(id: 1)
      expect(described_class.new(id: 1)).not_to eq(id: '1')
    end
  end
end
