# frozen_string_literal: true

module TestProf
  module FactoryProf
    # Wrap #run method with FactoryProf tracking
    module FabricationPatch
      def create(name, overrides={})
        TestProf::FactoryProf::FactoryBuilders::Fabrication.track(name) { super }
      end
    end
  end
end
