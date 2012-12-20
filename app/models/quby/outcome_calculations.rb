require 'active_support/concern'

module Quby
  module OutcomeCalculations
    extend ActiveSupport::Concern

    included do
      before_save :set_scores

      def set_scores
        results = calculate_builders
        self.scores = results.select(&:score)
        self.actions = results.select(&:alerting)
        self.completion = results.select(&:completion).first || {}
      end
    end

    def action
      alarm_scores      = scores.select {|key, value| value["status"].to_s == "alarm" }
      alarm_answers     = actions[:alarm] || []
      attention_scores  = scores.select {|key, value| value["status"].to_s == "attention" }
      attention_answers = actions[:attention] || []

      return :alarm     if alarm_scores.any?     or alarm_answers.any?
      return :attention if attention_scores.any? or attention_answers.any?
      nil
    end

    def calculate_builders
      results = {}

      questionnaire.score_builders.each do |key, builder|
        begin
          result = ScoreCalculator.calculate(self.value_by_regular_values,
                                             self.patient.andand.slice("birthyear", "gender"),
                                             results,
                                             &builder.calculation)
          result.reverse_merge!(builder.options) if builder.score
          results[key] = result
        rescue StandardError => e
          results[key] = {:exception => e.message,
                               :backtrace => e.backtrace}.reverse_merge(builder.options)
        end
      end

      results
    end

    # Calculate scores and actions, write to the database but bypass any validations
    # This function is called by parts of the system that only want to calculate
    # stuff, and can't help it if an answer is not completed.
    def update_scores
      self.class.skip_callback :save, :before, :set_scores
      calculate_builders
      update_attribute(:scores, scores)
      update_attribute(:actions, actions)
      update_attribute(:completion, completion)
      self.class.set_callback :save, :before, :set_scores
    end
  end
end