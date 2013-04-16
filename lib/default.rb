# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'slim'
Slim::Engine.set_default_options :pretty => true

require "time"
require "nokogiri"
require "pygments"

include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Filtering
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::HTMLEscape

def header
  render '_header'
end

def time_tag(item, key=:created_at)
  time         = Time.parse(item[key])
  datetime     = time.strftime("%Y-%m-%d")
  display_time = time.strftime("%d %B %Y")

  "<time datetime='#{h(datetime)}'>#{h(display_time)}</time>"
end

def maruku(code)
  Nanoc3::Filter.named(:maruku).new(@item_rep.assigns).run(code)
end

def maruku_strip(code)
  html = maruku(code)
  doc  = Nokogiri::HTML.fragment(html)
  doc.text
end

class SyntaxFilter < Nanoc3::Filter
  identifier :syntax

  def run(content, params={})
    doc = Nokogiri::HTML.fragment(content)
    code_blocks = doc.search('pre>code')

    code_blocks.each do |block|
      code = block.text.strip
      first_line, remaining_lines = code.split("\n", 2)
      language = params[:language]

      if first_line =~ %r{^```(\w+)}
        language = $1
        code = remaining_lines
      end

      if language
        if params.fetch(:colour, true)
          highlighted_text = Pygments.highlight(code,
            lexer: language,
            formatter: 'html',
            options: { encoding: 'utf-8', nowrap: true })

          block.inner_html = highlighted_text
        else
          block.content = code
        end
      end
    end

    doc.to_html
  end
end

class PrependSummaryFilter < Nanoc3::Filter
  identifier :prepend_summary

  def run(content, params={})
    "".tap do |output|
      if item[:summary] and !item[:hide_summary]
        summary_html = maruku(item[:summary])
        output << "<div class='summary'>#{summary_html}</div><hr class='summary-break'/>"
      end

      output << content
    end
  end
end

class LiterateFilter < Nanoc3::Filter
  identifier :literate

  def run(content, params={})
    raise "no :literate key found" unless item[:literate]
    File.read("literate/" + item[:literate])
  end
end

