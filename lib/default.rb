# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'slim'
Slim::Engine.set_default_options :pretty => true

require "time"
require "nokogiri"

include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Filtering
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::HTMLEscape

def h1
  '<h1><a href="/">Aanand Prasad</a></h1>'
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
      text = block.text.strip
      first_line, rest = text.split("\n", 2)

      if first_line =~ %r{^```(\w+)}
        if params.fetch(:colour, true)
          command = "pygmentize -l #{$1} -f html -O encoding=utf-8,nowrap"

          highlighted_text = IO.popen(command, "r+") do |f|
            f.write(rest)
            f.close_write
            f.read
          end

          block.inner_html = highlighted_text
        else
          block.content = rest
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
      if item[:summary]
        summary_html = maruku(item[:summary])
        output << "<div class='summary'>#{summary_html}</div><hr class='summary-break'/>"
      end

      output << content
    end
  end
end
