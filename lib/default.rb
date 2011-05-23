# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require "time"
require "nokogiri"

include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Filtering
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::HTMLEscape

def time_tag(item)
  created_at   = Time.parse(item[:created_at])
  datetime     = created_at.strftime("%Y-%m-%d")
  display_time = created_at.strftime("%d %B %Y")

  "<time datetime='#{h(datetime)}'>#{h(display_time)}</time>"
end

def maruku(code)
  Nanoc3::Filter.named(:maruku).new(@item_rep.assigns).run(code)
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
