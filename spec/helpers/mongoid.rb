
module Mongoid
  def self.destructive_fields
    []
  end

  module Document
    def self.included(base)
      base.extend(ClassMethods)
    end

    def vocabularies
      self.class.vocabularies
    end

    module ClassMethods
      def field(*args)
      end

      def attr_accessible(*args)
      end
    end
  end
end
