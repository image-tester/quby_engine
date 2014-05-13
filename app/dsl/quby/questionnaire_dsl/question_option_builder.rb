module Quby
  module QuestionnaireDsl
    class QuestionOptionBuilder
      def initialize(questionnaire:, question:, key:, attributes:, default_question_options:)
        @questionnaire = questionnaire
        @question = question
        @default_question_options = default_question_options || {}
        @question_option = QuestionOption.new(key, question, attributes)
      end

      def build(&block)
        instance_eval(&block) if block
        @question_option
      end

      def question(key, attributes = {}, &block)
        if @questionnaire.key_in_use? key
          fail "#{@questionnaire.key}:#{key}: A question or option with input key #{key} is already defined."
        end

        question_builder = QuestionBuilder.new(key, question_attributes(attributes))
        question_builder.instance_eval(&block) if block
        question = question_builder.build
        @questionnaire.question_hash[key] = question
        @question_option.questions << question
      end

      private

      def question_attributes(attributes)
        @default_question_options.merge(attributes)
                                 .merge(questionnaire: @questionnaire,
                                        parent: @question,
                                        parent_option_key: @question_option.key)
      end
    end
  end
end
