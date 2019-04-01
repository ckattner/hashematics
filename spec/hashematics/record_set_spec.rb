# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Hashematics::RecordSet do
  let(:csv_rows) { csv_fixture('data.csv') }

  let(:record_set) { described_class.new }

  subject { record_set }

  specify '#rows returns the original dataset' do
    csv_rows.each { |row| subject.add(row) }

    expect(subject.rows).to eq(csv_rows)
  end
end
