# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe ::Hashematics::Graph do
  let(:csv_rows) { csv_fixture('data.csv') }

  let(:configuration) { yaml_fixture('config.yml') }

  let(:people) { yaml_fixture('people.yml') }

  let(:groups) { ::Hashematics::Configuration.new(configuration).groups }

  describe '#children' do
    it 'returns list of child group names' do
      graph = described_class.new(groups).add(csv_rows)

      actual_children = graph.children

      expected_children = groups.map(&:name)

      expect(actual_children).to eq(expected_children)
    end
  end

  describe '#data' do
    context 'with no object_class specifications' do
      it 'should parse configuration and return object graph' do
        graph = described_class.new(groups).add(csv_rows)

        actual_people = graph.data('people')

        # binding.pry

        expect(actual_people).to eq(people)
      end
    end

    context 'with object_class open_struct specifications' do
      let(:modified_configuration) do
        yaml_fixture('config.yml').tap do |c|
          c.dig('types', 'person')['object_class'] = 'open_struct'
        end
      end

      let(:modified_groups) do
        ::Hashematics::Configuration.new(modified_configuration).groups
      end

      let(:modified_people) do
        yaml_fixture('people.yml').map { |h| OpenStruct.new(h) }
      end

      it 'should parse configuration and return object graph' do
        graph = described_class.new(modified_groups).add(csv_rows)

        actual_people = graph.data(:people)

        expect(actual_people).to eq(modified_people)
      end
    end
  end

  describe 'README examples' do
    specify 'Getting Started should work' do
      rows = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner'
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark'
        }
      ]

      graph = ::Hashematics.graph(rows: rows)
      objects = graph.rows

      expect(objects).to eq(rows)
    end

    specify 'Introduction to Shaping should work' do
      config = {
        types: {
          person: {
            properties: %i[id first]
          }
        },
        groups: {
          avengers: {
            by: :id,
            type: :person
          }
        }
      }

      rows = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner'
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark'
        }
      ]

      graph = ::Hashematics.graph(config: config, rows: rows)
      objects = graph.data(:avengers)

      expected = [
        {
          id: 1,
          first: 'Bruce'
        },
        {
          id: 2,
          first: 'Tony'
        }
      ]

      expect(objects).to eq(expected)
    end

    specify 'Cross-Mapping Shape Attribute Names should work' do
      config = {
        types: {
          person: {
            properties: {
              id_number: :id,
              first_name: :first
            }
          }
        },
        groups: {
          avengers: {
            by: :id,
            type: :person
          }
        }
      }

      rows = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner'
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark'
        }
      ]

      graph   = ::Hashematics.graph(config: config, rows: rows)
      objects = graph.data(:avengers)

      expected = [
        {
          id_number: 1,
          first_name: 'Bruce'
        },
        {
          id_number: 2,
          first_name: 'Tony'
        }
      ]

      expect(objects).to eq(expected)
    end

    specify 'Nested Shaping should work' do
      config = {
        types: {
          person: {
            properties: {
              id: 'ID #',
              first: 'First Name',
              last: 'Last Name'
            }
          },
          costume: {
            properties: {
              id: 'Costume ID #',
              name: 'Costume Name',
              color: 'Costume Color'
            }
          }
        },
        groups: {
          avengers: {
            by: 'ID #',
            type: :person,
            groups: {
              costumes: {
                by: 'Costume ID #',
                type: :costume
              }
            }
          }
        }
      }

      rows = [
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 3,
          'Costume Name' => 'Basic Hulk',
          'Costume Color' => 'Green'
        },
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 4,
          'Costume Name' => 'Mad Hulk',
          'Costume Color' => 'Red'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 5,
          'Costume Name' => 'Mark I',
          'Costume Color' => 'Gray'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 6,
          'Costume Name' => 'Mark IV',
          'Costume Color' => 'Red'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 7,
          'Costume Name' => 'Mark VI',
          'Costume Color' => 'Nano-Blue'
        }
      ]

      graph   = ::Hashematics.graph(config: config, rows: rows)
      objects = graph.data(:avengers)

      expected = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner',
          costumes: [
            { id: 3, name: 'Basic Hulk', color: 'Green' },
            { id: 4, name: 'Mad Hulk', color: 'Red' }
          ]
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark',
          costumes: [
            { id: 5, name: 'Mark I', color: 'Gray' },
            { id: 6, name: 'Mark IV', color: 'Red' },
            { id: 7, name: 'Mark VI', color: 'Nano-Blue' }
          ]
        }
      ]

      expect(objects).to eq(expected)
    end

    specify 'Multiple Top-Level Graphs should work' do
      config = {
        types: {
          person: {
            properties: {
              id: 'ID #',
              first: 'First Name',
              last: 'Last Name'
            }
          },
          costume: {
            properties: {
              id: 'Costume ID #',
              name: 'Costume Name',
              color: 'Costume Color'
            }
          }
        },
        groups: {
          avengers: {
            by: 'ID #',
            type: :person,
            groups: {
              costumes: {
                by: 'Costume ID #',
                type: :costume
              }
            }
          },
          costumes: {
            by: 'Costume ID #',
            type: :costume
          }
        }
      }

      rows = [
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 3,
          'Costume Name' => 'Basic Hulk',
          'Costume Color' => 'Green'
        },
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 4,
          'Costume Name' => 'Mad Hulk',
          'Costume Color' => 'Red'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 5,
          'Costume Name' => 'Mark I',
          'Costume Color' => 'Gray'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 6,
          'Costume Name' => 'Mark IV',
          'Costume Color' => 'Red'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => 7,
          'Costume Name' => 'Mark VI',
          'Costume Color' => 'Nano-Blue'
        }
      ]

      graph   = ::Hashematics.graph(config: config, rows: rows)
      objects = graph.data(:costumes)

      expected = [
        { id: 3, name: 'Basic Hulk', color: 'Green' },
        { id: 4, name: 'Mad Hulk', color: 'Red' },
        { id: 5, name: 'Mark I', color: 'Gray' },
        { id: 6, name: 'Mark IV', color: 'Red' },
        { id: 7, name: 'Mark VI', color: 'Nano-Blue' }
      ]

      expect(objects).to eq(expected)
    end

    specify 'Handling Blanks (skip - default) should work' do
      config = {
        types: {
          person: {
            properties: {
              id: 'ID #',
              first: 'First Name',
              last: 'Last Name'
            }
          },
          costume: {
            properties: {
              id: 'Costume ID #',
              name: 'Costume Name',
              color: 'Costume Color'
            }
          }
        },
        groups: {
          avengers: {
            by: 'ID #',
            type: :person,
            groups: {
              costumes: {
                by: 'Costume ID #',
                type: :costume
              }
            }
          },
          costumes: {
            by: 'Costume ID #',
            type: :costume
          }
        }
      }

      rows = [
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 3,
          'Costume Name' => 'Basic Hulk',
          'Costume Color' => 'Green'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => '',
          'Costume Name' => '',
          'Costume Color' => ''
        },
        {
          'Costume ID #' => 4,
          'Costume Name' => 'Undercover',
          'Costume Color' => 'Purple'
        }
      ]

      graph    = ::Hashematics.graph(config: config, rows: rows)
      avengers = graph.data(:avengers)
      costumes = graph.data(:costumes)

      expected_avengers = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner',
          costumes: [
            { id: 3, name: 'Basic Hulk', color: 'Green' }
          ]
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark',
          costumes: []
        }
      ]

      expected_costumes = [
        { id: 3, name: 'Basic Hulk', color: 'Green' },
        { id: 4, name: 'Undercover', color: 'Purple' }
      ]

      expect(avengers).to eq(expected_avengers)
      expect(costumes).to eq(expected_costumes)
    end

    specify 'Handling Blanks (include) should work' do
      config = {
        types: {
          person: {
            properties: {
              id: 'ID #',
              first: 'First Name',
              last: 'Last Name'
            }
          },
          costume: {
            properties: {
              id: 'Costume ID #',
              name: 'Costume Name',
              color: 'Costume Color'
            }
          }
        },
        groups: {
          avengers: {
            by: 'ID #',
            include_blank: true,
            type: :person,
            groups: {
              costumes: {
                by: 'Costume ID #',
                type: :costume
              }
            }
          },
          costumes: {
            by: 'Costume ID #',
            include_blank: true,
            type: :costume
          }
        }
      }

      rows = [
        {
          'ID #' => 1,
          'First Name' => 'Bruce',
          'Last Name' => 'Banner',
          'Costume ID #' => 3,
          'Costume Name' => 'Basic Hulk',
          'Costume Color' => 'Green'
        },
        {
          'ID #' => 2,
          'First Name' => 'Tony',
          'Last Name' => 'Stark',
          'Costume ID #' => '',
          'Costume Name' => '',
          'Costume Color' => ''
        },
        {
          'Costume ID #' => 4,
          'Costume Name' => 'Undercover',
          'Costume Color' => 'Purple'
        }
      ]

      graph    = ::Hashematics.graph(config: config, rows: rows)
      avengers = graph.data(:avengers)
      costumes = graph.data(:costumes)

      expected_avengers = [
        {
          id: 1,
          first: 'Bruce',
          last: 'Banner',
          costumes: [
            { id: 3, name: 'Basic Hulk', color: 'Green' }
          ]
        },
        {
          id: 2,
          first: 'Tony',
          last: 'Stark',
          costumes: []
        },
        {
          id: nil,
          first: nil,
          last: nil,
          costumes: [
            { id: 4, name: 'Undercover', color: 'Purple' }
          ]
        }
      ]

      expected_costumes = [
        { id: 3, name: 'Basic Hulk', color: 'Green' },
        { id: '', name: '', color: '' },
        { id: 4, name: 'Undercover', color: 'Purple' }
      ]

      expect(avengers).to eq(expected_avengers)
      expect(costumes).to eq(expected_costumes)
    end
  end
end
