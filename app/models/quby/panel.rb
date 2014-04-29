module Quby
  class Panel
    attr_accessor :title
    attr_accessor :items
    attr_accessor :key
    attr_reader :questionnaire

    def initialize(questionnaire:)
      @questionnaire = questionnaire
      @items = []
    end

    def as_json(options = {})
      {class: self.class.to_s, title: title, items: items}
    end

    def index
      @questionnaire.panels.index(self)
    end

    def next
      this_panel_index = index

      if this_panel_index < @questionnaire.panels.size
        return @questionnaire.panels[this_panel_index + 1]
      else
        nil
      end
    end

    def prev
      this_panel_index = index

      if this_panel_index > 0
        return @questionnaire.panels[this_panel_index - 1]
      else
        nil
      end
    end

    def validations
      vals = {}
      items.each do |item|
        if item.is_a? Quby::Items::Question
          item.options.each do |opt|
            if opt.questions
              opt.questions.each do |q|
                vals[q.key] = q.validations
              end
            end
          end
          vals[item.key] = item.validations
        end
      end
      vals
    end
  end
end
