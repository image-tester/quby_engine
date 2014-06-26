require 'quby/score_calculation'

module Quby
  module DSL
    class ScoreBuilder
      attr_reader :key
      attr_reader :calculation

      def initialize(key, options = {}, &block)
        @score = ::Quby::ScoreCalculation.new(key, options, &block)
      end

      def build
        @score
      end
    end
  end
end
