require 'spec_helper'

module Quby
  describe Panel do
    it "should be possible to instantiate" do
      expect { Quby::Panel.new(questionnaire: double) }.to_not raise_error
    end
  end
end
