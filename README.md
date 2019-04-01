# Hashematics

[![Gem Version](https://badge.fury.io/rb/hashematics.svg)](https://badge.fury.io/rb/hashematics) [![Build Status](https://travis-ci.org/bluemarblepayroll/hashematics.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/hashematics) [![Maintainability](https://api.codeclimate.com/v1/badges/a171325c301e58eb4fb0/maintainability)](https://codeclimate.com/github/bluemarblepayroll/hashematics/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/a171325c301e58eb4fb0/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/hashematics/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Hashematics is a configuration-based object graphing tool which can turn a flat, single dimensional dataset into a structure of deeply nested objects.

## Installation

To install through Rubygems:

````
gem install install hashematics
````

You can also add this to your Gemfile:

````
bundle add hashematics
````

## Examples

### Getting Started

Take the following simple, non-nested data set:

id | first | last
-- | ----- | ------
1  | Bruce | Banner
2  | Tony  | Stark

We could read this in using the following configuration:

```ruby
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

graph  = ::Hashematics.graph(rows: rows)
objects = graph.rows
```

The variable `objects` will now contain the same data as `rows`.  This, so far, is not very useful but it sets up base case.

### Introduction to Simple Shaping

Let's say that we only want id and first variables:

```ruby
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

graph  = ::Hashematics.graph(config: config, rows: rows)
objects = graph.data(:avengers)
```

Notice how we are grouping the data and calling the #data API.  Now the `objects` variable should now look like:

```ruby
[
  {
    id: 1,
    first: 'Bruce'
  },
  {
    id: 2,
    first: 'Tony'
  }
]
```

### Cross-Mapping Shape Attribute Names

Say we wanted to change the attribute names:

```ruby
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

graph  = ::Hashematics.graph(config: config, rows: rows)
objects = graph.data(:avengers)
```

The `objects` variable should now look like:

```ruby
[
  {
    id_number: 1,
    first_name: 'Bruce'
  },
  {
    id_number: 2,
    first_name: 'Tony'
  }
]
```

### Nested Shaping

Let's build on our initial data set to:

* include child data (one-to-many) relationship
* start with different attributes (cross map attribute names)

ID # | First Name | Last Name | Costume ID # | Costume Name | Costume Color
---- | ---------- | --------- | ------------ | ------------ | -------------
1    | Bruce      | Banner    | 3            | Basic Hulk   | Green
1    | Bruce      | Banner    | 4            | Mad Hulk     | Red
2    | Tony       | Stark     | 5            | Mark I       | Gray
2    | Tony       | Stark     | 6            | Mark IV      | Red
2    | Tony       | Stark     | 7            | Mark VI      | Nano-Blue

We could now read this in as:

```ruby
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

graph  = ::Hashematics.graph(config: config, rows: rows)
objects = graph.data(:avengers)
```

The `objects` variable should now look like:

```ruby
[
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
```

Shaping / grouping is recursive and should support richer breadth as well as depth graphs.

### Multiple Top-Level Graphs

You are not limited to just one top-level graph.  For example, we could expand on the previous example to include another grouping of costumes:

```ruby
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

graph  = ::Hashematics.graph(config: config, rows: rows)
objects = graph.data(:costumes)
```

The `objects` variable should now look like:

```ruby
[
  { id: 3, name: 'Basic Hulk', color: 'Green' },
  { id: 4, name: 'Mad Hulk', color: 'Red' },
  { id: 5, name: 'Mark I', color: 'Gray' },
  { id: 6, name: 'Mark IV', color: 'Red' },
  { id: 7, name: 'Mark VI', color: 'Nano-Blue' }
]
```

### Handling Blanks

Records with blank ID's are ignored by default.  This is due to the flat nature of the incoming data.  Take the following example:

ID # | First Name | Last Name | Costume ID # | Costume Name | Costume Color
---- | ---------- | --------- | ------------ | ------------ | -------------
1    | Bruce      | Banner    | 3            | Basic Hulk   | Green
2    | Tony       | Stark     |              |              |
     |            |           | 4            | Undercover   | Purple

This is interpreted as:

* Bruce Banner is an avenger and has 2 costumes
* Tony Stark is an avenger but has no costumes
* An undercover purple costume exists, but belongs to no avenger

We could read this in while ignoring blank IDs (default):

```ruby
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

graph   = ::Hashematics.graph(config: config, rows: rows)
avengers = graph.data(:avengers)
costumes = graph.data(:costumes)
```

The `avengers` variable should now look like:

```ruby
[
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
```

The `costumes` variable should now look like:

```ruby
[
  { id: 3, name: 'Basic Hulk', color: 'Green' },
  { id: 4, name: 'Undercover', color: 'Purple' }
]
```

If you wish to include blank objects, then pass in ```include_blank: true``` option into the group configuration:

```ruby
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

graph   = ::Hashematics.graph(config: config, rows: rows)
avengers = graph.data(:avengers)
costumes = graph.data(:costumes)
```

The `avengers` variable should now look like:

```ruby
[
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
```

The `costumes` variable should now look like:

```ruby
[
  { id: 3, name: 'Basic Hulk', color: 'Green' },
  { id: '', name: '', color: '' },
  { id: 4, name: 'Undercover', color: 'Purple' }
]
```

### Advanced Options

Some other options available are:

* Custom Object Types: `object_class` attribute for a type defaults to Hash but can be set as a class constant or a proc/lambda.  If it is a class constant, then a new instance will be initialized from the incoming Hash.  If it is a function then it will be called with the incoming hash passed in and expecting an object as a return.
* Compoound Unique Identifiers: `by` can either be a string, symbol, or array.

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check hashematics.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/hashematics.git)
4. Navigate to the root folder (cd hashematics)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````
bundle exec guard
````

Also, do not forget to run Rubocop:

````
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update ```lib/hashematics/version.rb``` using [semantic versioning](https://semver.org/)
3. Install dependencies: ```bundle```
4. Update ```CHANGELOG.md``` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Build the project locally: `gem build hashematics`
7. Publish package to RubyGems: `gem push hashematics-X.gem` where X is the version to push
8. Tag master with new version: `git tag <version>`
9. Push tags remotely: `git push origin --tags`

## License

This project is MIT Licensed.
