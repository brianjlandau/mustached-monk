Ohm ॐ
=====

Object-hash mapping library for Redis.


Description
-----------

Ohm is a library for storing objects in
[Redis](http://code.google.com/p/redis/), a persistent key-value
database. It includes an extensible list of validations and has very
good performance.


Getting started
---------------

Install [Redis](http://code.google.com/p/redis/). On most platforms
it's as easy as grabbing the sources, running make and then putting the
`redis-server` binary in the PATH.

Once you have it installed, you can execute `redis-server` and it will
run on `localhost:6379` by default. Check the `redis.conf` file that comes
with the sources if you want to change some settings.

If you don't have Ohm, try this:

    $ sudo gem install ohm

Or you can grab the code from [http://github.com/soveran/ohm](http://github.com/soveran/ohm).

Now, in an irb session you can test the Redis adapter directly:

    >> require "ohm"
    => true
    >> Ohm.connect
    => []
    >> Ohm.redis.set "Foo", "Bar"
    => "OK"
    >> Ohm.redis.get "Foo"
    => "Bar"


Models
------

Ohm's purpose in life is to map objects to a key value datastore. It
doesn't need migrations or external schema definitions. Take a look at
the example below:

### Example

    class Event < Ohm::Model
      attribute :name
      set :participants
      list :comments
      counter :votes

      index :name

      def validate
        assert_present :name
      end
    end

All models have the `id` attribute built in, you don't need to declare it.

This is how you interact with ids:

    event = Event.create :name => "Ohm Worldwide Conference 2031"
    event.id
    # => 1

    # Find an event by id
    event == Event[1]
    # => true

    # Trying to find a non existent event
    Event[2]
    # => nil

This example shows some basic features, like attribute declarations and
validations. Keep reading to find out what you can do with models.

Attribute types
---------------

Ohm::Model provides four attribute types: `attribute`, `set`, `list` and
`counter`.

### attribute

An `attribute` is just any value that can be stored as a string. In the
example above, we used this field to store the Event's `name`. You can
use it to store numbers, but be aware that Redis will return a string
when you retrieve the value.

### set

A `set` in Redis is an unordered list, with an external behavior similar
to that of Ruby arrays, but optimized for faster membership lookups.
It's used internaly by Ohm to keep track of the instances of each model
and for generating and maintaining indexes.

### list

A `list` is like an array in Ruby. It's perfectly suited for queues and
for keeping elements in order.

### counter

A `counter` is like a regular attribute, but the direct manipulation
of the value is not allowed. You can retrieve, increase or decrease
the value, but you can not assign it. In the example above, we used a
counter attribute for tracking votes. As the incr and decr operations
are atomic, you can rest assured a vote won't be counted twice.

Associations
------------

Ohm lets you use collections (lists and sets) to represent associations.
For this, you only need to provide a second paramenter when declaring a
list or a set:

    set :attendees, Person

After this, everytime you refer to `event.attendees` you will be talking
about instances of the model `Person`. If you want to get the raw values
of the set, you can use `event.attendees.raw`.

The `attendees` collection also exposes two sorting methods: `sort`
returns the elements ordered by `id`, and `sort_by` receives a parameter
with an attribute name, which will determine the sorting order. Both
methods receive an options hash which is explained in the documentation
for {Ohm::Attributes::Collection#sort}.

Adding instances of `Person` to the attendees hash is done with the
`add` method:

    @event.attendees.add(Person.create(name: "Albert"))

    # And now...
    @event.attendees.each do |person|
      # ...do what you want with this person.
    end

Just to clarify: when you add items to a set with `<<`, Ohm inserts
whatever you send without checking it. When you use `add`, it assumes
it's an instance of some `Ohm::Model` and stores its id.


Indexes
-------

An index is a set that's handled automatically by Ohm. For any index declared,
Ohm maintains different sets of objects ids for quick lookups.

For example, in the example above, the index on the name attribute will
allow for searches like Event.find(:name, "some value").

Note that the `assert_unique` validation and the methods `find`, `search` and `filter` need a
corresponding index in order to work.

### Finding

You can find a collection of records with the `find` method:

    # This returns a collection of users with the username "Albert"
    User.find(username: "Albert")

### Searching and filtering

    # This returns a collection of users with usernames "Albert" or "Benoit"
    User.search(username: ["Albert", "Benoit"]) do |search_results|
      @users = search_results.all
    end

    # This returns a collection of users with usernames "Albert" or "Benoit",
    # but only those with the account enabled.
    User.search(username: ["Albert", "Benoit"]) do |search_results|
      search_results.filter(account: "enabled") do |filter_results|
        @users = filter_results.all
      end
    end

Important: note that both `search` and `filter` yield the results
to a block. This is important because the set of results is stored
for the duration of the block (to allow for chaining of searches and
filters), but is deleted once the block ends. The `.all` is necessary
for retrieving the actual instances, as keeping a reference to a set
that is going to be deleted would only return empty sets.

Validations
-----------

Before every save, the `validate` method is called by Ohm. In the method
definition you can use assertions that will determine if the attributes
are valid. Nesting assertions is a good practice, and you are also
encouraged to create your own assertions. You can trigger validations at
any point by calling `valid?` on a model instance.


Assertions
-----------

Ohm ships with some basic assertions. Check Ohm::Validations to see
the method definitions.

### assert

The `assert` method is used by all the other assertions. It pushes the
second parameter to the list of errors if the first parameter evaluates
to false.

    def assert(value, error)
      value or errors.push(error) && false
    end

### assert_present

Checks that the given field is not nil or empty. The error code for this
assertion is :not_present.

    assert_present :name

### assert_format

Checks that the given field matches the provided format. The error code
for this assertion is :format.

    assert_format :username, /^\w+$/

### assert_numeric

Checks that the given field holds a number as a Fixnum or as a string
representation. The error code for this assertion is :not_numeric.

    assert_numeric :votes

### assert_unique

Validates that the attribute or array of attributes are unique.
For this, an index of the same kind must exist. The error code is :not_unique.

    assert_unique :email

Errors
------

When an assertion fails, the error report is added to the errors array.
Each error report contains two elements: the field where the assertion
was issued and the error code.

### Validation example

Given the following example:

    def validate
      assert_present :foo
      assert_numeric :bar
      assert_format :baz, /^\d{2}$/
      assert_unique :qux
    end

If all the assertions fail, the following errors will be present:

    obj.errors
    # => [[:foo, :not_present], [:bar, :not_numeric], [:baz, :format], [:qux, :not_unique]]

Presenting errors
-----------------

Unlike other ORMs, that define the full error messages in the model
itself, Ohm encourages you to define the error messages outside. If
you are using Ohm in the context of a web framework, the views are the
proper place to write the error messages.

Ohm provides a presenter that helps you in this quest. The basic usage
is as follows:

    error_messages = @model.errors.present do |e|
      e.on [:name, :not_present], "Name must be present"
      e.on [:account, :not_present], "You must supply an account"
    end

    error_messages
    # => ["Name must be present", "You must supply an account"]

Having the error message definitions in the views means you can use any
sort of helpers. You can also use blocks instead of strings for the
values. The result of the block is used as the error message:

    error_messages = @model.errors.present do |e|
      e.on [:email, :not_unique] do
        "The email #{@model.email} is already registered."
      end
    end

    error_messages
    # => ["The email foo@example.com is already registered."]
