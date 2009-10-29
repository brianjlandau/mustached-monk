require 'digest/md5'

module SDocHelpers
  module MarkdownFiles
    def description
      return super unless full_name =~ /\.(md|markdown)$/
      # assuming your path is ROOT/html or ROOT/doc
      path = Dir.pwd + '/../' + full_name
      Markdown.new(gfm(File.read(path))).to_html + open_links_in_new_window
    end

    def open_links_in_new_window
      <<-html
<script type="text/javascript">$(function() {
  $('a').each(function() { $(this).attr('target', '_blank') })
})</script>
html
    end
    
    private
    
    def gfm(text)
      # Extract pre blocks
      extractions = {}
      text.gsub!(%r{<pre>.*?</pre>}m) do |match|
        md5 = Digest::MD5.hexdigest(match)
        extractions[md5] = match
        "{gfm-extraction-#{md5}}"
      end

      # prevent foo_bar_baz from ending up with an italic word in the middle
      text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x|
        x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
      end

      # in very clear cases, let newlines become <br /> tags
      text.gsub!(/(\A|^$\n)(^\w[^\n]*\n)(^\w[^\n]*$)+/m) do |x|
        x.gsub(/^(.+)$/, "\\1  ")
      end

      # Insert pre block extractions
      text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
        extractions[$1]
      end

      text
    end
  end
end

begin
  require 'rdiscount'
  RDoc::TopLevel.send :include, SDocHelpers::MarkdownFiles
rescue LoadError
  puts "Markdown support not enabled. Please install RDiscount."
end
