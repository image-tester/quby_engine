require 'spec_helper'

module Quby
  describe Questionnaire do
    def quest(definition, key="rspectest")
        questionnaire = Questionnaire.new(:key => key)
        questionnaire.stub!(:definition).and_return(definition)
        questionnaire.enhance_by_dsl
        questionnaire
    end  
    
    it "should be possible to create a new questionnaire with a key" do
      @q = quest("title \"hallo wereld\"")
      @q.save!.should be_true
    end
    
    it "should require a key to create" do
      @q = quest("title \"hallo wereld\"", nil)
      expect{@q.save!}.should raise_error
    end
    
    it "should support panels" do
      @q = quest("panel {}")

      @q.panels.size.should == 1
      @q.panels[0].class.should == Items::Panel
    end
    
    it "should support questions" do
      @q = quest("question(:myid, :title => 'Question 1') {}")

      @q.panels.size.should == 1
      @q.panels[0].items[0].class.should == Items::Question
    end
    
    it "should support text" do
      @q = quest("text 'The quick brown fox jumps over the lazy dog.'")

      @q.panels.size.should == 1
      @q.panels[0].items[0].class.should == Items::Text
    end

    it "should return a flat list of items in the questionnaire" do
      questionnaire = <<-END
        question :q01i, :type => :radio do
          title "Foo"
          option :a01, :description => "Foo1" do
            question(:q01sub, :type => :string, :title => "Blaat") {}
          end
        end

        question :q02 do
          title "Bar"
        end
      END

      @q = quest(questionnaire)
      @q.questions.length.should == 3
    end

    it "should return a tree of items in the questionnaire" do
      questionnaire = <<-END
        question :q01i, :type => :radio do
          title "Foo"
          option :a01, :description => "Foo1" do
            question(:q01sub, :type => :string, :title => "Blaat") {}
          end
        end

        question :q02 do
          title "Bar"
        end
      END

      @q = quest(questionnaire)
      @q.questions_tree.should be_an Array
      
      pending "write more expectations"
    end
    
    it "should not accept duplicate question keys" do
      questionnaire = <<-END
        question :q01, :type => :radio 

        question :q01 
      END

      quest(questionnaire).send(:validate_definition_syntax).should be_false
    end
    
    it "should not accept checkbox option keys that are the same as other question keys" do
      questionnaire = <<-END
        question :q01, :type => :radio 

        question :q02, :type => :checkbox do 
          option :q03
          option :a1
        end 
        
        question :q03, :type => :radio 
      END

      quest(questionnaire).send(:validate_definition_syntax).should be_false
    end
    
    context "with some answers" do
    
      before(:each) do
        questionnaire = <<-END
          default_answer_value :q01 => "antwoord"
          question :q01, :type => :string, :title => "Blaat" 
        END

        @q = quest(questionnaire)
        unless @q.save
          pp @q.errors and raise "Error saving questionnaire"
        end
        
        @q.answers.create!(:questionnaire_id => @q.id)
        @q.answers.create!(:questionnaire_id => @q.id)
        @q.answers.create!(:questionnaire_id => @q.id)
      end
      
      it "should have some answers" do
        @q.answers.count.should == 3
      end
      
      it "should destroy dependent answers when questionnaire is destroyed" do
        id = @q.id
        @q.destroy
        Answer.where(:questionnaire_id => id).should be_empty
      end
    end

  end
end