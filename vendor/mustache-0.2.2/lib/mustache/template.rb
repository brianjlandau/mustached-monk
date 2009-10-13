require 'cgi'

class Mustache
  # A Template is a compiled version of a Mustache template.
  #
  # The idea is this: when handed a Mustache template, convert it into
  # a Ruby string by transforming Mustache tags into interpolated
  # Ruby.
  #
  # You shouldn't use this class directly.
  class Template
    # Expects a Mustache template as a string along with a template
    # path, which it uses to find partials.
    def initialize(source, template_path = '.', template_extension = 'html')
      @source = source
      @template_path = template_path
      @template_extension = template_extension
      @tmpid = 0
    end

    # Renders the `@source` Mustache template using the given
    # `context`, which should be a simple hash keyed with symbols.
    def render(context)
      # Compile our Mustache template into a Ruby string
      compiled = "def render(ctx) #{compile} end"

      # Here we rewrite ourself with the interpolated Ruby version of
      # our Mustache template so subsequent calls are very fast and
      # can skip the compilation stage.
      instance_eval(compiled, __FILE__, __LINE__ - 1)

      # Call the newly rewritten version of #render
      render(context)
    end

    # Does the dirty work of transforming a Mustache template into an
    # interpolation-friendly Ruby string.
    def compile(src = @source)
      "\"#{compile_sections(src)}\""
    end

    # {{#sections}}okay{{/sections}}
    #
    # Sections can return true, false, or an enumerable.
    # If true, the section is displayed.
    # If false, the section is not displayed.
    # If enumerable, the return value is iterated over (a `for` loop).
    def compile_sections(src)
      res = ""
      while src =~ /\{\{\#(.+)\}\}\s*(.+)\{\{\/\1\}\}\s*/m
        # $` = The string to the left of the last successful match
        res << compile_tags($`)
        name = $1.strip.to_sym.inspect
        code = compile($2)
        ctxtmp = "ctx#{tmpid}"
        res << ev("(v = ctx[#{name}]) ? v.respond_to?(:each) ? "\
          "(#{ctxtmp}=ctx.dup; r=v.map{|h|ctx.update(h);#{code}}.join; "\
          "ctx.replace(#{ctxtmp});r) : #{code} : ''")
        # $' = The string to the right of the last successful match
        src = $'
      end
      res << compile_tags(src)
    end

    # Find and replace all non-section tags.
    # In particular we look for four types of tags:
    # 1. Escaped variable tags - {{var}}
    # 2. Unescaped variable tags - {{{var}}}
    # 3. Comment variable tags - {{! comment}
    # 4. Partial tags - {{< partial_name }}
    def compile_tags(src)
      res = ""
      while src =~ /\{\{(!|<|\{)?([^\/#]+?)\1?\}\}+/
        res << str($`)
        case $1
        when '!'
          # ignore comments
        when '<'
          res << compile_partial($2.strip)
        when '{'
          res << utag($2.strip)
        else
          res << etag($2.strip)
        end
        src = $'
      end
      res << str(src)
    end

    # Partials are basically a way to render views from inside other views.
    def compile_partial(name)
      klass = Mustache.classify(name)
      if Object.const_defined?(klass)
        ev("#{klass}.render")
      else
        src = File.read("#{@template_path}/#{name}.#{@template_extension}")
        compile(src)[1..-2]
      end
    end

    # Generate a temporary id, used when compiling code.
    def tmpid
      @tmpid += 1
    end

    # Get a (hopefully) literal version of an object, sans quotes
    def str(s)
      s.inspect[1..-2]
    end

    # {{}} - an escaped tag
    def etag(s)
      ev("CGI.escapeHTML(ctx[#{s.strip.to_sym.inspect}].to_s)")
    end

    # {{{}}} - an unescaped tag
    def utag(s)
      ev("ctx[#{s.strip.to_sym.inspect}]")
    end

    # An interpolation-friendly version of a string, for use within a
    # Ruby string.
    def ev(s)
      "#\{#{s}}"
    end
  end
end
