require 'spec_helper'

module Quby
  describe QuestionOption do
    let(:questionnaire) do
      questionnaire = Quby::Questionnaire.new("test", <<-END)
        question :one, type: :radio do
          title "Testvraag"
          option :a1, value: 1, description: "Option oneone", hides_questions: [:two]
          option :a2, value: 1, description: "Option onetwo", hides_questions: [:three]
          option :a3, value: 1, description: "Option onethree", hides_questions: [:four]
          option :a4, value: 1, description: "Option onefour", shows_questions: [:five]
        end

        question :two, type: :radio
        question :three, type: :radio
        question :four, type: :radio
        question :five, type: :radio

        question :checkb, type: :check_box do
          title "Checkbox vraag"
          option :sixone, value: 1, description: "Option sixone"
          option :sixtwo, value: 2, description: "Option sixtwo"
        end
      END
      questionnaire
    end

    describe "#hides_questions" do
      it "returns an array with the keys of the questions that are hidden when this option is picked" do
        questionnaire.question_hash[:one].options.first.hides_questions.should == [:two]
      end
    end

    describe "#shows_questions" do
      it "returns an array with the keys of the questions that are shown when this option is picked" do
        questionnaire.question_hash[:one].options.last.shows_questions.should == [:five]
      end
    end

    describe "#input_key" do
      it 'returns the key for checkbox questions' do
        option = questionnaire.question_hash[:checkb].options.first
        expect(option.input_key).to eq :sixone
      end

      it 'returns <question_key>_<option_key> for radio questions' do
        option = questionnaire.question_hash[:one].options.first
        expect(option.input_key).to eq :one_a1
      end
    end

    describe '#key_in_use?' do
      let(:option) do
        question    = Items::Question.new(:v_1, type: :radio)
        subquestion = Items::Question.new(:v_1_op1_v1)

        question_option = QuestionOption.new(:op1, question, value: 1, description: "")
        question_option.questions << subquestion
        question_option
      end
      it 'bla' do
        expect(option.input_key).to eq :v_1_op1
      end

      it 'returns true if the key is the option key' do
        expect(option.key_in_use?(:v_1_op1)).to eql true
      end
      it 'returns true if the key is a sub questions key' do
        expect(option.key_in_use?(:v_1_op1_v1)).to eql true
      end
      it 'return false if the key is not in use' do
        expect(option.key_in_use?(:v_1_op1_v2)).to eql false
      end
    end
  end
end
