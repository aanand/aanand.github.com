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

def highlight_syntax(content)
  doc = Nokogiri::HTML.fragment(content)
  code_blocks = doc.search('pre>code')

  code_blocks.each do |block|
    text = block.text.strip
    first_line, rest = text.split("\n", 2)

    if first_line =~ %r{^```(\w+)}
      command = "pygmentize -l #{$1} -f html -O encoding=utf-8,nowrap"

      puts command

      highlighted_text = IO.popen(command, "r+") do |f|
        f.write(rest)
        f.close_write
        f.read
      end

      block.inner_html = highlighted_text
    end
  end

  puts doc.to_html

  doc.to_html
end
