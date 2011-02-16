require 'maruku'

#Replace {{var_name}} with <span class='text_var' text_var=var_name></span> 
#TODO: add ability to specify default text to use in case text_var is empty

TextVar = /(\{\{)(.+)(\}\})/

MaRuKu::In::Markdown.register_span_extension(
  :chars => 123, #ASCII ordinal of {
  :regexp => TextVar,
  :handler => lambda do |doc, src, con|
    m = src.read_regexp3(TextVar)
    var_name = m.captures.compact[1]
    string = "<span class='text_var' text_var='#{var_name}'>{{#{var_name}}}</span>"
    con.push doc.md_html(string)
    #con.push doc.md_html("<p>raw html</p>")
    true
end)