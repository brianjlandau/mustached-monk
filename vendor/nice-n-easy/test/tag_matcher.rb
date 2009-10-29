require 'active_support'
require 'rexml/document'
require 'action_controller/vendor/html-scanner'
require 'action_controller/assertions/selector_assertions'

module TagMatchingAssertions
  include ActionController::Assertions::SelectorAssertions
  
  def assert_tag_in(*opts)
    target = opts.shift
    tag_opts = find_tag_opts(opts)
    assert !find_tag_in(target, tag_opts).nil?, 
           "#{tag_opts.inspect} was not found in \n#{target.inspect}"
  end
  
  # Identical to +assert_tag_in+, but asserts that a matching tag does _not_
  # exist. (See +assert_tag_in+ for a full discussion of the syntax.)
  def assert_tag_not_in(*opts)
    target = opts.shift
    tag_opts = find_tag_opts(opts)
    assert find_tag_in(target, tag_opts).nil?, 
           "#{tag_opts.inspect} was found in \n#{target.inspect}"
  end
  
  def assert_select_in(*args, &block)
    if @selected
      root = HTML::Node.new(nil)
      root.children.concat @selected
    else
      # Start with mandatory target.
      target = args.shift
      root = HTML::Document.new(target, false, false).root
    end
    assert_select(*args.unshift(root), &block)
  end
  
  private
  
    def find_tag_opts(opts)
      if opts.size > 1
        find_opts = opts.last.merge({ :tag => opts.first.to_s })
      else
        find_opts = opts.first.is_a?(Symbol) ? { :tag => opts.first.to_s } : opts.first
      end
      find_opts
    end

    def find_tag_in(target, opts = {})
      target = HTML::Document.new(target, false, false)
      target.find(opts)
    end
end
