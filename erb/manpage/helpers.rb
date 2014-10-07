# Folds each endline into a single space, escapes special man characters,
# reverts HTML entity references back to their original form, strips trailing
# whitespace and, optionally, appends a newline
def manify(str, append_newline = true, preserve_space = false)
  if preserve_space
    str = str.gsub("\t", (' ' * 8))
  else
    str = str.tr_s("\n\t ", ' ')
  end
  str
      .gsub(/\./, '\\\&.')
      .gsub('-', '\\-')
      .gsub('&lt;', '<')
      .gsub('&gt;', '>')
      .gsub('&#8201;&#8212;&#8201;', ' \\(em ')
      .gsub('&#8203;', '') # NOTE remove zero-width space as it's something specific for HTML output
      .gsub('&#8212;', '\\-\\-')
      .gsub('&#8217;', '\\(cq')
      .gsub('&#8230;', '\\\&...')
      .gsub('\'', '\\*(Aq')
      .rstrip + (append_newline ? "\n" : '')
end
