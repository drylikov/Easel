
require 'spec_helper'

class TestVocabulary < RDF::Vocabulary
  property :foo
  property :bar
end

describe Easel do
  subject do
    TestVocabulary
  end

  describe 'Mixin methods' do
    it 'should add properties method to the extended class' do
      subject.should respond_to(:properties)
    end
  end

  describe 'properties' do
    it 'should properly extract declared properties' do
      subject.properties.should == [:foo, :bar]
    end
  end
end
