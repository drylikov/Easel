
require 'rdf'

module RDF
  class Vocabulary
    def self.properties
      self.singleton_methods - RDF::Vocabulary.singleton_methods
    end
  end
end
