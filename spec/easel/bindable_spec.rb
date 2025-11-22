
require 'spec_helper'

describe Easel do
  subject do
    Class.new(Object) do
      include Easel::Bindable
      include Mongoid::Document
    end
  end

  describe 'Mixin methods' do
    it 'should add bind_to method to the extended class' do
      subject.should respond_to(:bind_to)
    end

    it 'should add to_rdf method to instances of the extended class' do
      subject.new.should respond_to(:to_rdf)
    end
  end

  describe 'bind_to' do
    it 'basic usage should create field definitions for each vocabulary entry' do
      vocab = double(:properties => [:bacon, :ham, :sausage])
      vocab.properties.each do |p|
        subject.should_receive(:field).with(p, {})
        subject.should_receive(:attr_accessible).with(p)
      end

      subject.bind_to(vocab)
    end

    it 'should properly handle multiple calls to multiple vocabularies' do
      vocab1 = double(:properties => [:bacon, :ham, :sausage])
      vocab1.properties.each do |p|
        subject.should_receive(:field).with(p, {})
        subject.should_receive(:attr_accessible).with(p)
      end
      vocab2 = double(:properties => [:beef, :meatballs, :hamburger])
      vocab2.properties.each do |p|
        subject.should_receive(:field).with(p, {})
        subject.should_receive(:attr_accessible).with(p)
      end

      subject.bind_to(vocab1)
      subject.bind_to(vocab2)
    end

    it 'should set default options as requested' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, :as => :delicious, :localized => true)
      subject.should_receive(:attr_accessible).with(:bacon)

      subject.bind_to(vocab, :as => :delicious, :localized => true )
    end

    it 'should properly set the options on mapped fields as requested' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, :as => :delicious, :localized => true)
      subject.should_receive(:attr_accessible).with(:bacon)

      subject.bind_to(vocab, :mapping => {:bacon => { :as => :delicious, :localized => true }})
    end

    it 'should only set options on the mapped field' do
      vocab = double(:properties => [:bacon, :ham])
      subject.should_receive(:field).with(:bacon, :as => :delicious)
      subject.should_receive(:field).with(:ham, {})
      subject.should_receive(:attr_accessible).with(:bacon)
      subject.should_receive(:attr_accessible).with(:ham)
      subject.bind_to(vocab, :mapping => {:bacon => { :as => :delicious }})
    end

    it 'should override default options if asked to in the mapping' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, { :localized => false })
      subject.should_receive(:attr_accessible).with(:bacon)
      subject.bind_to(vocab, :localized => true, :mapping => { :bacon => { :localized => false }})
    end

    it 'should not make attributes accessible if asked not to' do
      vocab = double(:properties => [:bacon])
      subject.should_receive(:field).with(:bacon, {})
      subject.should_not_receive(:attr_accessible).with(:bacon)
      subject.bind_to(vocab, :accessible => false)
    end

    it 'should not make mapped attributes accessible if asked not to' do
      vocab = double(:properties => [:bacon, :ham])
      subject.should_receive(:field).with(:bacon, {})
      subject.should_receive(:field).with(:ham, {})
      subject.should_receive(:attr_accessible).with(:bacon)
      subject.should_not_receive(:attr_accessible).with(:ham)
      subject.bind_to(vocab, :mapping => { :ham => { :accessible => false}})
    end

    it 'should only bind to :only fields specified by array' do
      vocab = double(:properties => [:bacon, :ham])
      subject.should_receive(:field).with(:bacon, {})
      subject.should_receive(:attr_accessible).with(:bacon)

      subject.bind_to(vocab, :only => [:bacon])
    end

    it 'should only set default options on :only field' do
      vocab = double(:properties => [:bacon, :ham])
      subject.should_receive(:field).with(:bacon, :as => :delicious)
      subject.should_receive(:attr_accessible).with(:bacon)
      subject.bind_to(vocab, :as => :delicious, :only => [:bacon])
    end

    it 'should only set options on :only field' do
      vocab = double(:properties => [:bacon, :ham])
      subject.should_receive(:field).with(:bacon, :as => :delicious)
      subject.should_receive(:attr_accessible).with(:bacon)
      subject.bind_to(vocab, :only => {:bacon => { :as => :delicious }})
    end

  end

  describe 'to_rdf' do
    it 'should properly convert fields with values set' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      vocab = double('vocab', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new
      o.should_receive(:[]).with(:bacon).any_number_of_times.and_return('yummy')
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, 'yummy']
      end
    end

    it 'should properly convert fields which are enumerable' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      vocab = double('vocab', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      subject.bind_to(vocab)
      o = subject.new
      o.should_receive(:[]).with(:bacon).any_number_of_times.and_return(['crispy', 'back', 'peameal'])
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, 'crispy']
        graph << [uri, bacon, 'back']
        graph << [uri, bacon, 'peameal']
      end
    end


    it 'should properly convert all declared vocabularies' do
      uri = RDF::URI.new('http://example.com')
      bacon = RDF::URI.intern('bacon')
      ham = RDF::URI.intern('ham')
      beef = RDF::URI.intern('beef')
      meatballs = RDF::URI.intern('meatballs')
      vocab1 = double('vocab 1', :bacon => bacon, :ham => ham, :properties => [:bacon, :ham])
      vocab2 = double('vocab 2', :beef => beef, :meatballs => meatballs, :properties => [:beef, :meatballs])
      subject.bind_to(vocab1)
      subject.bind_to(vocab2)
      o = subject.new
      o.should_receive(:[]).with(:bacon).any_number_of_times.and_return('yummy')
      o.should_receive(:[]).with(:ham).and_return(nil)
      o.should_receive(:[]).with(:beef).any_number_of_times.and_return('yucky')
      o.should_receive(:[]).with(:meatballs).and_return(nil)
      o.to_rdf(uri).should == RDF::Graph.new do |graph|
        graph << [uri, bacon, 'yummy']
        graph << [uri, beef, 'yucky']
      end
    end
  end
end
