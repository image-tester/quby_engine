Quby.V2 ?= {}

Quby.V2.Questionnaire = React.createClass
  displayName: 'Questionnaire'
  render: ->
    React.DOM.form {className: "#{@props.questionnaire.key} paged"},
      _.map @props.questionnaire.panels, (panel) =>
        Quby.V2.Panel {panel: panel, answer: @props.answer}

Quby.V2.Panel = React.createClass
  displayName: 'Panel'
  render: ->
    React.DOM.fieldset {className: "panel"},
      React.DOM.h1 {}, @props.panel.title
      _.map @props.panel.items, (item) =>
        Quby.V2.Item {item: item, answer: @props.answer}

Quby.V2.Item = React.createClass
  displayName: 'Item'
  render: ->
    switch @props.item.class
      when "Quby::Items::Text"
        Quby.V2.Item.Text @props
      else
        React.DOM.div {}, @props.item

Quby.V2.Item.Text = React.createClass
  displayName: 'Item'
  render: ->
    React.DOM.div {dangerouslySetInnerHTML: {__html: @props.item.text}}