# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Hashematics::Category do
  let(:csv_rows) { csv_fixture('data.csv') }

  it 'should require an id_key' do
    expect { described_class.new(id_key: nil) }.to raise_error ArgumentError
  end

  describe '#add' do
    context 'with id key but no parent key' do
      specify '#records should return last unique rows as records' do
        category = described_class.new(id_key: 'ID #')

        csv_rows.each do |csv_row|
          record = ::Hashematics::Record.new(csv_row)
          category.add(record)
        end

        expected_records = [
          ::Hashematics::Record.new(csv_rows[3]),
          ::Hashematics::Record.new(csv_rows[5]),
          ::Hashematics::Record.new(csv_rows[7])
        ]

        expect(category.records).to eq(expected_records)
      end
    end

    context 'with parent and id keys' do
      specify '#records should return unique rows as records specific to a parent' do
        category = described_class.new(
          parent_key: 'ID #',
          id_key: 'Car ID #'
        )

        csv_rows.each do |csv_row|
          record = ::Hashematics::Record.new(csv_row)
          category.add(record)
        end

        expected_records = [
          ::Hashematics::Record.new(csv_rows[2]),
          ::Hashematics::Record.new(csv_rows[3])
        ]

        parent = ::Hashematics::Record.new(csv_rows.first)

        expect(category.records(parent)).to eq(expected_records)
      end
    end
  end
end
