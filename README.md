# Requiring Files

## Learning Goals

- Recognize how code on different files can be loaded when running a single file
- Understand how to require files when running a Ruby application

## Introduction

So far, most of the labs we've seen have a similar file structure - they
typically have a `lib` folder and a `spec` folder and some files like
`README.md`:

```text
├── lib
│   └── ruby_file.rb
└── spec
    ├── ruby_file_spec.rb
    └── spec_helper.rb
├── Gemfile
├── README.md
```

As we expand our understanding of programming in Ruby and start to work with
larger, more complex applications, we'll start to see more pieces and components
being added - run files, environment files, to start. Then, we'll start seeing
things like database folders and before long, we'll see many files in many
folders, all doing their small part for the application.

With all these files separated out into different folders, how is it that they
are able to work together? In this lesson, we're going to provide an answer to this question and take a deeper
look at requiring files.

## Classes Defined in the Same File

Let's take a look at a pair of example classes to get started. If we define two
classes in the same file, we can interact with both classes immediately after
they are defined. Imagine if the following 'belongs-to' / 'has-many' example
between `Garden` and `Plant` classes:

```ruby
class Garden
  attr_accessor :name

  def initialize(name:)
    @name = name
  end

  def plants
    Plant.all.select do |plant|
      plant.garden == self
    end
  end
end

class Plant
  attr_accessor :garden, :name

  @@all = []

  def initialize(name:)
    @name = name
    @@all << self
  end

  def self.all
    @@all
  end
end

lawn = Garden.new(name: 'Front Lawn') # we can call Plant.new because Garden is defined above

basil = Plant.new(name: 'Basil') # we can call Plant.new because Plant is defined above
basil.garden = lawn

cucumber = Plant.new(name: 'Cucumber')
cucumber.garden = lawn # we can associate a plant and a garden because both are defined above

p lawn.plants
# => [#<Plant:0x00007fa4440ab0c8 @name="Basil", @garden=#<Garden:0x00007fa4440997b0 @name="Front Lawn">>, #<Plant:0x00007fa4440b8bd8 @name="Cucumber", @garden=#<Garden:0x00007fa4440997b0 @name="Front Lawn">>]
```

> **Note**: This code is available in `lib/example.rb` and can be tested by
running `ruby lib/example.rb`.

In the above code, we can call both `Garden` and `Plant` at the end because both
classes have been defined in the file. Notice, too, that `Garden` includes a
method, `plants`, that calls `Plant.all`. `Garden` _needs_ to know about the
`Plant` class, and with the setup above, it does.

## Classes Defined in Different Files

If we define the example classes in separate files, they won't automatically
know about each other or have access to one another. In the `lib` folder,
`Plant` and `Garden` are separated into their own files, `plant.rb` and
`garden.rb`.

```text
├── lib
│   └── example.rb
│   └── garden.rb
│   └── plant.rb
├── CONTRIBUTING.md
├── LICENSE.md
├── README.md
```

In `lib/garden.rb`, below the `Garden` class, the same code from the previous
example is written:

```ruby
# lib/garden.rb

# ...

lawn = Garden.new(name: 'Front Lawn')

basil = Plant.new(name: 'Basil')
basil.garden = lawn

cucumber = Plant.new(name: 'Cucumber')
cucumber.garden = lawn

p lawn.plants
```

At the moment, if we try to run the file (`ruby lib/garden.rb`), we get an error
regarding an `uninitialized constant Plant (NameError)`. For one file to have
access to code written in another file, we need to tell Ruby to _require_ that
other file.

## Define `require_relative` and `require`

By requiring a file, we are telling Ruby, 'go load the that code exists in this file.'
We have two ways to tell Ruby to do this: `require_relative` and `require`.

#### `require_relative`

[require_relative][] accepts a _relative file path_ to the file
we want to require. This means we're providing a file path that starts from the
file in which the `require_relative` statement is called.

[require_relative]: https://apidock.com/ruby/Kernel/require_relative

```ruby
require_relative '../lib/ruby_file.rb'
```

In the example above, `..` would mean that inside the _parent folder_ of the
_current file_ being run, there should be a `lib` folder with a file inside it,
`ruby_file.rb`. When dealing with applications that have many neighboring files,
we'll be using `require_relative`.

Since an application can be installed in many places on a computer, any internal
file requirements should be relative to each other.

#### `require`

[require][] accepts an _absolute file path_, meaning a file location
relative to the _root_ directory. `require` will also accept shortened names,
and checks if any matches are found in the directories located in your shell's
[PATH variable][].

[require]: https://apidock.com/ruby/v2_5_5/Kernel/require
[PATH variable]: http://www.linfo.org/path_env_var.html

We don't often require files using their absolute path, but we will frequently
require files using a shortened name. You may have already seen this:

```ruby
require 'pry'
```

Pry is a Gem, a bundle of preexisting code that we can install on our computers.
When we write `require 'pry'`, we are telling Ruby to load that bundle of code
up before continuing. Once loaded, we will have access to whatever classes and
modules are defined in `pry`.

## Requiring `plant.rb` from `garden.rb`

Now that we know the syntax for requiring files, we can apply it to our example
of `lib/garden.rb` and `lib/plant.rb`. At the top of `lib/garden.rb`, add the
following line:

```ruby
require_relative './plant.rb'
```

Here, we're indicating to Ruby that there is a file, `plant.rb` located in the
same folder relative to the current file. With this added, if you try
`ruby lib/garden.rb` again, you should see it print out the expected `Plant`
instances.

In this example, we only have two classes, but with `require_relative`, we
can have as many classes as we want, each in a separate file. As long as
they are all required in the file that we run, they'll get loaded.

### Local Variables

It is important to note that both `require` and `require_relative` will not
load local variables - _only_ functions, modules, and classes.

## Conclusion

Ruby applications are often divided up among many files, and when an application
runs, it typically needs a way to _load_ those various files so it has access to
all the code.

You've experienced this many times already - every time you work on a Ruby lab
and run the tests, the files where you write your solution are being loaded into
the files that are running the tests. This is done through a file called
`spec_helper.rb`.

The exact workings of RSpec and the `spec_helper.rb` file are beyond the scope
of this lesson, but the underlying premise is the same as what we did in this
lesson.

This is so common and so critical to Ruby applications that it became common to
include a file dedicated to the task of requiring files and loading up any
needed code when an application is run. In the next lesson, we'll take a closer
look at this file, typically known as `environment.rb`.
