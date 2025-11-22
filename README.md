




# Easel





Easel lets you easily bind RDF vocabulary definitions to Mongoid models, letting
you easily define your models in terms of RDF vocabularies and access
RDF.rbrepresentations of your models. This is in
contrast to the two common ways of working with RDF data in practice today:

1. Maintaining your data as 'pure' RDF via a project like
RDF.rb. This is great for exposing the power of
RDF but doesn't square with conventional Mongoid / Rails stacks.

2. Maintaining your data within a conventional Rails environment, and 'doing RDF' by exporting
XML that happens to look like RDF-XML. This is fine for exposing resources as
RDF, but passes over the great capabilities that RDF provides over and above
serialization.

Easel lets you live in between these two extremes. It helps you do this by doing
two things:

1. Providing a `bind_to` class method that lets you define the fields on your
Mongoid model in terms of any number of RDF vocabularies. After binding to, say,
the `DC` Vocabulary, your model will have fields corresponding to all of the
properties defined in the `DC` vocabulary, including `#title`, `#author`, and
all others. These fields are normal Mongoid fields, and can be manipulated,
saved and queried just like any other field.

2. Providing a `#to_rdf` method on instances of the model that converts all
properties defined by a bound vocabulary into an RDF::Graph object. This graph
object can then be serialized into any format you desire, queried directly, or
used for any other purpose within the RDF.rb universe.

## How do I use it?

Simply add a `bind_to` declaration in your Mongoid class for each RDF vocabulary
you want to bind to. You can then call `#to_rdf` on any instances of that model:



    class Example
      include Mongoid::Document
      include Easel::Bindable

      bind_to RDF::DC
    end

    e = Example.new(:title => "Of Mice and Men")
    e.to_rdf #=> An RDF::Graph containing a triple describing a DC.title of "Of
    Mice and Men"

## Getting fancy

By default, `bind_to` will create fields for every property in the named
vocabulary, each of type `String`. Easel provides some flexibility with this,
via the following options:

* **Default Options**: Any extra arguments passed to `bind_to` will be copied
  through to each call to `field`. This makes it easy to set global options,
  such as localize flags. By way of example, a line such as this:

        bind_to RDF:DC, :localize => true

  will cause Easel to create a Mongoid field for each property in `RDF::DC`,
  with `:localize => true` as an option to each of them.

* **Mapping Options**: There are many cases where you only want to specify extra
  mongoid properties for specific fields. Easel allows you to do this by way of
  the `mapping` option. To wit:

        bind_to RDF::DC, :mapping => { :title => { :default => "Untitled" } }

  will cause Easel to create a `title` field via a call similar to the
  following:

        field :title, :default => "Untitled"

  Any number of property mappings can be specified inside the `mapping` option.
  It's important to note that all properties in the vocabulary are still bound
  to Mongoid fields; `mapping` merely changes the options passed to Mongoid for
  the listed properties.

* **Binding Specific Properties**: It's often the case that you only want to bind
  a few fields from a vocabulary into your model. Easel lets you do that by
  listing a set of field names to bind, using the `only` option:

        bind_to RDF::DC, :only => [:title]

  will create a Mongoid field for _only_ the `title` property. In addition to
  taking an array of property names, `only` also accepts a hash similar to the
  format of `mapping`:

        bind_to RDF::DC, :only => { :title => { :default => "Untitled" } }

  will cause Easel to _only_ create a field for `title`, passing the specified
  options into Mongoid. No other properties from the `RDF::DC` vocabulary are
  created on the model. As with `mapping`, any number of fields may be specified
  in an `only` option.

