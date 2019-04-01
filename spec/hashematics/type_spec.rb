# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'
require 'examples/person'

describe ::Hashematics::Type do
  let(:input) do
    {
      id: 1,
      first: 'Matt',
      middle: 'Elfy',
      last: 'Rizzo'
    }
  end

  let(:person) { Person.new(input) }

  context 'when input is an object' do
    context 'with no properties and object does not respond to keys' do
      specify '#convert makes blank object' do
        type = described_class.new

        actual = type.convert(person)

        expect(actual).to eq({})
      end
    end
  end

  context 'when input is a hash' do
    context 'with no properties but object responds to keys' do
      specify '#convert makes object' do
        type = described_class.new

        actual = type.convert(input)

        expect(actual).to eq(input)
      end
    end

    context 'with property array' do
      let(:properties) { [:id, 'first', :last] }

      context 'with proc/lambda object_class' do
        let(:expected) do
          {
            id: '1 - Processed',
            'first' => 'Matt - Processed',
            last: 'Rizzo - Processed'
          }
        end

        let(:object_class) do
          lambda do |h|
            h.map { |k, v| [k, "#{v} - Processed"] }.to_h
          end
        end

        specify '#convert makes object' do
          type = described_class.new(properties: properties, object_class: object_class)

          actual = type.convert(input)

          expect(actual).to eq(expected)
        end
      end

      context 'with class object_class' do
        specify '#convert makes object' do
          type = described_class.new(properties: properties, object_class: Person)

          actual = type.convert(input)

          expect(actual).to eq(person)
        end
      end

      context 'with nil object_class' do
        let(:expected) do
          {
            id: 1,
            'first' => 'Matt',
            last: 'Rizzo'
          }
        end

        specify '#convert makes object' do
          type = described_class.new(properties: properties)

          actual = type.convert(input)

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
