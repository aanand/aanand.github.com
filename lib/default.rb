# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require "time"

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
