require 'spec_helper'

describe "Answers" do
  Questionnaire.all.each do |questionnaire|
    describe "GET /questionnaires/#{questionnaire.key}/answers/some_id" do
      it "should return HTTP 200 for all questionnaires in paged mode" do
        answer = Answer.find_or_create_by_test_and_questionnaire_id(:test => true, 
                                                                    :value => questionnaire.default_answer_value, 
                                                                    :questionnaire_id => questionnaire.id)
        timestamp = Time.now.getgm.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        plain_hmac = [::Settings.shared_secret, answer.token, timestamp].join('|')
        hmac = Digest::SHA1.hexdigest(plain_hmac)
        get edit_questionnaire_answer_path(questionnaire, answer, 
                                           :token => answer.token, 
                                           :display_mode => 'paged', 
                                           :timestamp => timestamp, 
                                           :hmac => hmac)
        response.status.should be(200)
      end
    end
  end
end