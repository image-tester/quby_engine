require 'spec_helper'

module Quby
  describe Questionnaire do
    describe "persistence" do
      let(:key)           { 'test' }
      let(:definition)    { "title 'My Test'" }
      let(:questionnaire) { Questionnaire.new(key, definition) }

      before do
        @file = Tempfile.new("questionnaire_spec")
        @file.close
        questionnaire.stub(:path) { @file.path }
      end

      after do
        @file.unlink
      end

      it "should save to disk" do
        questionnaire.save
        File.open(@file.path, 'r').read.should == definition
      end

      it "should not save Windows linebreaks" do
        questionnaire.definition = "title 'My Test'\r\nshort_description 'Test questionnaire'"
        questionnaire.save
        File.open(@file.path, 'r').read.should == "title 'My Test'\nshort_description 'Test questionnaire'"
      end
    end

    describe ".all" do
      it "marks questionnaires as persisted" do
        Dir.stub(:[] => ["key.rb"])
        quest = Quby::Questionnaire.all.first
        quest.persisted?.should be_true
      end
    end

    describe ".find_by_key" do
      it "marks a questionnaire as persisted" do
        Quby::Questionnaire.stub(:exists? => true)
        quest = Quby::Questionnaire.find_by_key "key"
        quest.persisted?.should be_true
      end
    end

    describe "validations" do
      it "should be valid for a valid questionnaire" do
        Questionnaire.new("test", "title \"hallo wereld\"").should be_valid
      end

      it "should require a key" do
        Questionnaire.new(nil, "title \"hallo wereld\"").should_not be_valid
      end

      it "rejects a key when a questionnaire with this key already exists" do
        Quby::Questionnaire.stub(:exists? => true)
        Questionnaire.new("k_s_4", "title \"hallo wereld\"").should_not be_valid
      end

      describe "should no file with a given key exist" do
        before { Quby::Questionnaire.stub(:exists? => false) }

        it "requires that the key starts with a letter" do
          Questionnaire.new("4ks", "title \"hallo wereld\"").should_not be_valid
        end

        it "requires that the key contains no capitals" do
          Questionnaire.new("Ks", "title \"hallo wereld\"").should_not be_valid
        end

        it "requires that the key contains no dashes" do
          Questionnaire.new("k-s", "title \"hallo wereld\"").should_not be_valid
        end

        it "requires that the key contains no whitespace" do
          Questionnaire.new("k s", "title \"hallo wereld\"").should_not be_valid
        end

        it "accepts a key containing lower case letters, numbers and underscores that start with a letter" do
          Questionnaire.new("k_s_4", "title \"hallo wereld\"").should be_valid
        end
      end

      describe "should a file exist for this key" do
        before { Quby::Questionnaire.stub(:exists? => true) }

        it "accepts any key" do
          quest = Questionnaire.new("4 K-s", "title \"hallo wereld\"")
          quest.persisted = true
          quest.should be_valid
        end
      end
    end

    describe '#scores' do
      Questionnaire.new("test").scores.should == []
    end

    describe '#to_codebook' do
      let(:definition)    { "title 'My Test' \n question(:v_1, :type => :radio) { option :a1, :value => 0; option :a2, :value => 1}" }
      let(:questionnaire) { Questionnaire.new("test", definition) }
      let(:definition_html_unsafe)    { "title 'My Test' \n question(:v_1, :type => :radio, :title => ' < 20') { option :a1, :value => 0; option :a2, :value => 1}" }
      let(:questionnaire_html) { Questionnaire.new("test2", definition_html_unsafe) }

      it "should be able to generate a codebook" do
        questionnaire.to_codebook.should be
      end

      it "should not break off a codebook when encountering <" do
        questionnaire_html.to_codebook.should == "My Test\nDate unknown\n\ntest2_1 radio \n\" < 20\"\n0\t\"\"\n1\t\"\"\n"
      end
    end

    #it "should support panels" do
      #@q = quest("panel {}")

      #@q.panels.size.should == 1
      #@q.panels[0].class.should == Items::Panel
    #end

    #it "should support questions" do
      #@q = quest("question(:myid, :title => 'Question 1') {}")

      #@q.panels.size.should == 1
      #@q.panels[0].items[0].class.should == Items::Question
    #end

    #it "should support text" do
      #@q = quest("text 'The quick brown fox jumps over the lazy dog.'")

      #@q.panels.size.should == 1
      #@q.panels[0].items[0].class.should == Items::Text
    #end

    #it "should return a flat list of items in the questionnaire" do
      #questionnaire = <<-END
        #question :q01i, :type => :radio do
          #title "Foo"
          #option :a01, :description => "Foo1" do
            #question(:q01sub, :type => :string, :title => "Blaat") {}
          #end
        #end

        #question :q02 do
          #title "Bar"
        #end
      #END

      #@q = quest(questionnaire)
      #@q.questions.length.should == 3
    #end

    #it "should return a tree of items in the questionnaire" do
      #questionnaire = <<-END
        #question :q01i, :type => :radio do
          #title "Foo"
          #option :a01, :description => "Foo1" do
            #question(:q01sub, :type => :string, :title => "Blaat") {}
          #end
        #end

        #question :q02 do
          #title "Bar"
        #end
      #END

      #@q = quest(questionnaire)
      #@q.questions_tree.should be_an Array

      #pending "write more expectations"
    #end

    #it "should not accept duplicate question keys" do
      #questionnaire = <<-END
        #question :q01, :type => :radio

        #question :q01
      #END

      #quest(questionnaire).send(:validate_definition_syntax).should be_false
    #end

    #it "should not accept checkbox option keys that are the same as other question keys" do
      #questionnaire = <<-END
        #question :q01, :type => :radio

        #question :q02, :type => :checkbox do
          #option :q03
          #option :a1
        #end

        #question :q03, :type => :radio
      #END

      #quest(questionnaire).send(:validate_definition_syntax).should be_false
    #end

    #context "with some answers" do
      #before(:each) do
        #questionnaire = <<-END
          #default_answer_value :q01 => "antwoord"
          #question :q01, :type => :string, :title => "Blaat"
        #END

        #@q = quest(questionnaire)
        #unless @q.save
          ##pp @q.errors and raise "Error saving questionnaire"
        #end

        #@q.answers.create!(:questionnaire_id => @q.id)
        #@q.answers.create!(:questionnaire_id => @q.id)
        #@q.answers.create!(:questionnaire_id => @q.id)
      #end

      #it "should have some answers" do
        #@q.answers.count.should == 3
      #end

      #it "should destroy dependent answers when questionnaire is destroyed" do
        #id = @q.id
        #@q.destroy
        #Answer.where(:questionnaire_id => id).should be_empty
      #end
    #end
  end
end
