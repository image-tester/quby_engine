require 'spec_helper'
module Quby
  describe 'Age in scores' do
    it 'can access age in a real score calculation' do
      answer  = Quby.answers.create!('aged_score_interpretations',
                                     patient: {"birthyear" => 2000, "gender" => :male},
                                     completed_at: Time.now)

      outcome = Quby.answers.generate_outcome(answer)
      outcome.scores.should == {"tot" => {"label" => "Totaalscore",
                                          "value" => 10,
                                          "interpretation" => "Laag",
                                          "score" => true,
                                          "referenced_values" => []}}
    end
  end
end
