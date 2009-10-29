require 'sinatra/base'
unless Object.method_defined?(:blank?)
  require 'active_support/core_ext/blank'
end

module Sinatra #:nodoc:
  module NiceEasyHelpers
    # :stopdoc:
    BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked selected).to_set
    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map(&:to_sym))
    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
    # :startdoc:
    
    # Creates a link to a given URL with the given text as the link.
    #   link "Check this out", '/path/to/something' # =>
    #     <a href="/path/to/something">Check this out</a>
    #
    def link(content, href, options = {})
      tag :a, content, options.merge(:href => href)
    end
    
    # Creates an image tag for the given image file.
    # If a relative source is given it assumes it lives in <tt>/images/</tt> on your server.
    #   image_tag "button.jpg" :alt => 'Do some Action' # =>
    #     <img src="/images/button.jpg" alt="Do some Action" />
    #
    #   image_tag "/icons/delete.jpg" :alt => 'Remove', :class => 'small-button' # =>
    #     <img src="/icons/delete.jpg" alt="Remove" class="small-button" />
    #
    #   image_tag "http://www.example.com/close.jpg" # =>
    #     <img src="http://www.example.com/close.jpg" />
    #
    def image_tag(src, options = {})
      single_tag :img, options.merge(:src => compute_public_path(src, 'images'))
    end
    
    # Creates a script tag for each source provided. If you just supply a relative filename
    # (with or without the .js extension) it will assume it can be found in your public/javascripts
    # directory. If you provide an absolute path it will use that.
    #
    #   javascript_include_tag 'jquery' # =>
    #     <script src="/javascripts/jquery.js" type="text/javascript"></script>
    #
    #   javascript_include_tag 'jquery', 'jquery-ui.min.js' # =>
    #     <script src="/javascripts/jquery.js" type="text/javascript"></script>
    #     <script src="/javascripts/jquery-ui.min.js" type="text/javascript"></script>
    #
    #   javascript_include_tag '/js/facebox.js' # =>
    #     <script src="/js/facebox.js" type="text/javascript"></script>
    #
    #   javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js' # =>
    #     <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js" type="text/javascript"></script>
    #
    def javascript_include_tag(*sources)
      sources.inject([]) { |tags, source|
        tags << tag(:script, '', {:src => compute_public_path(source, 'javascripts', 'js'), :type => 'text/javascript'})
        tags
      }.join("\n")
    end
    
    # :call-seq:
    #   stylesheet_link_tag(*sources, options = {})
    #
    # This helper is used to create a set of link tags for CSS stylesheets. If you just
    # supply a relative filename (with or without the .css extension) it will assume it
    # can be found in your public/javascripts directory. If you provide
    # an absolute path it will use that. You can also pass attributes for the link tag
    # in a hash as the last argument.
    #
    #   stylesheet_link_tag 'global' # =>
    #     <link href="/stylesheets/global.css" rel="stylesheet" type="text/css" media="screen" />
    #
    #   stylesheet_link_tag 'global' # =>
    #     <link href="/stylesheets/global.css" rel="stylesheet" type="text/css" media="screen" />
    #
    def stylesheet_link_tag(*sources)
      options = sources.extract_options!.symbolize_keys
      sources.inject([]) { |tags, source|
        tags << single_tag(:link, {:href => compute_public_path(source, 'stylesheets', 'css'),
                                   :type => 'text/css', :rel => 'stylesheet', :media => 'screen'}.merge(options))
        tags
      }.join("\n")
    end
    
    # :call-seq:
    #   label(field, options = {})
    #   label(obj, field, options = {})
    #
    # Creates a label tag for the specified field, which may be a field on an object.
    # It will use the field name as the text for the label unless a <tt>:text</tt>
    # option is provided.
    #
    #   label :email # =>
    #     <label for="email">Email</label>
    #
    #   label :email, :text => "Email Address:" # =>
    #     <label for="email">Email Address:</label>
    #
    #   label :user, :email # =>
    #     <label for="user_email">Email</label>
    #
    def label(*args)
      obj, field, options = extract_options_and_field(*args)
      text = options.delete(:text)
      if text.blank?
        if String.method_defined?(:titleize)
          text = field.blank? ? obj.to_s.titleize : field.to_s.titleize
        else
          text = field.blank? ? obj.to_s : field.to_s
        end
      end
      tag :label, text, options.merge(:for => (field.blank? ? obj : "#{obj}_#{field}"))
    end
    
    # :call-seq:
    #   text_field(field, options = {})
    #   text_field(obj, field, options = {})
    #
    # Returns a text input for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will auto-populate the input.
    #
    #   text_field :email # =>
    #     <input type="text" name="email" id="email" />
    #
    #   # Where the @params[:email] value is set already to "joe@example.com"
    #   text_field :email # =>
    #     <input type="text" name="email" id="email" value="joe@example.com" />
    #
    #   text_field :user, :email # =>
    #     <input type="text" name="user[email]" id="user_email" />
    #
    #   @user = User.new(:email => 'joe@example.com')
    #   text_field @user, :email # =>
    #     <input type="text" name="user[email]" id="user_email" value="joe@example.com" />
    #
    def text_field(*args)
      input_tag 'text', *args
    end
    
    # :call-seq:
    #   password_field(field, options = {})
    #   password_field(obj, field, options = {})
    #
    # Returns a password input for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will auto-populate the input.
    #
    #   password_field :password # =>
    #     <input type="password" name="password" id="password" />
    #
    #   # Where the @params[:password] value is set already to "secret"
    #   password_field :password # =>
    #     <input type="password" name="password" id="password" value="secret" />
    #
    #   password_field :user, :password # =>
    #     <input type="password" name="user[password]" id="user_password" />
    #
    #   @user = User.new(:password => 'secret')
    #   password_field @user, :password # =>
    #     <input type="password" name="user[password]" id="user_password" value="secret" />
    #
    def password_field(*args)
      input_tag 'password', *args
    end
    
    # :call-seq:
    #   file_field(field, options = {})
    #   file_field(obj, field, options = {})
    #
    # Returns a file input for the specified field, which may be on an object.
    #
    #   file_field :picture # =>
    #     <input type="file" name="picture" id="picture" />
    #
    #   file_field :user, :picture # =>
    #     <input type="file" name="user[picture]" id="user_picture" />
    #
    #   @user = User.new
    #   file_field @user, :picture # =>
    #     <input type="file" name="user[picture]" id="user_picture" />
    #
    def file_field(*args)
      input_tag 'file', *args
    end
    
    # :call-seq:
    #   button(name, content, options = {})
    #   button(name, content, type = "submit", options = {})
    #
    # Creates a button element with the name/id and with the content provided.
    # Defaults to the submit type.
    #
    #   button "continue", "Save and continue" # =>
    #     <button id="continue" name="continue" type="submit">Save and continue</button>
    #   
    #   button "add-email", "Add another Email", 'button' # =>
    #     <button id="add-email" name="add-email" type="button">Add another Email</button>
    #
    def button(*args)
      options = args.extract_options!.symbolize_keys
      name = args.shift
      content = args.shift
      type = args.shift || 'submit'
      tag :button, content, options.merge(:type => type, :name => name, :id => name)
    end
    
    # :call-seq:
    #   text_area(field, options = {})
    #   text_area(obj, field, options = {})
    #
    # Returns a text area tag for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will auto-populate the input.
    #
    #   text_area :description # =>
    #     <textarea name="description" id="description"></textarea>
    #
    #   # Where the @params[:description] value is set already to "A brand new book."
    #   text_area :description # =>
    #     <textarea name="description" id="description">A brand new book.</textarea>
    #
    #   text_area :product, :description # =>
    #     <textarea name="product[description]" id="product_description"></textarea>
    #
    #   @product = Product.new(:description => 'A brand new book.')
    #   text_area @product, :description # =>
    #     <textarea name="product[description]" id="product_description"></textarea>
    #
    def text_area(*args)
      obj, field, options = extract_options_and_field(*args)
      value = get_value(obj, field)
      tag :textarea, value, options.merge(get_id_and_name(obj, field))
    end
    
    # Creates an image input field for the source and options provided.
    # The image source is calculated the same way it is for Sinatra::NiceEasyHelpers#image_tag
    #
    #   image_input "buttons/save_close.png", :alt => 'Save and close'
    #     <input type="image" src="buttons/save_close.png" alt="Save and close" />
    def image_input(src, options = {})
      single_tag :input, options.merge(:type => 'image', :src => compute_public_path(src, 'images'))
    end
    
    # Creates as submit input field with the text and options provided.
    #
    #   submit # =>
    #     <input type="submit" value="Save" />
    #
    #   submit 'Save and continue' # =>
    #     <input type="submit" value="Save and continue" />
    #     
    def submit(value = "Save", options = {})
      single_tag :input, options.merge(:type => "submit", :value => value)
    end
    
    # :call-seq:
    #   checkbox_field(field, options)
    #   checkbox_field(obj, field, options)
    #
    # Returns a checkbox input for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will mark this field as checked if it 
    # matches the value for the field.
    #
    #   checkbox_field :subscriptions, :value => 1 # =>
    #     <input type="checkbox" name="subscriptions" id="subscriptions" value="1" />
    #
    #   # Where the @params[:subscriptions] value is set already to "1"
    #   checkbox_field :subscriptions, :value => 1 # =>
    #     <input type="checkbox" name="subscriptions" id="subscriptions" value="1" checked="checked" />
    #
    #   checkbox_field :user, :subscriptions, :value => 1 # =>
    #     <input type="checkbox" name="user[subscriptions]" id="user_subscriptions" value="1" />
    #
    #   @user = User.new(:subscriptions => ['newsletters'])
    #   checkbox_field @user, :subscriptions, :value => 'newsletters' # =>
    #     <input type="checkbox" name="user[subscriptions]" id="user_subscriptions" value="newsletters" checked="checked" />
    #
    def checkbox_field(*args)
      input_tag 'checkbox', *args
    end
    
    # :call-seq:
    #   radio_button(field, options)
    #   radio_button(obj, field, options)
    #
    # Returns a radio button input for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will mark this field as checked if it 
    # matches the value for the field.
    #
    #   radio_button :education, :value => 'college' # =>
    #     <input type="radio" name="education" id="education" value="college" />
    #
    #   # Where the @params[:education] value is set already to "college"
    #   radio_button :education, :value => 'college # =>
    #     <input type="radio" name="education" id="education" value="college" checked="checked" />
    #
    #   radio_button :user, :education, :value => 'college' # =>
    #     <input type="radio" name="user[education]" id="user_education" value="college" />
    #
    #   @user = User.new(:education => 'college')
    #   radio_button @user, :education, :value => 'college' # =>
    #     <input type="radio" name="user[education]" id="user_education" value="college" checked="checked" />
    #
    def radio_button(*args)
      input_tag 'radio', *args
    end
    
    # :call-seq:
    #   select_field(field, choices, options = {})
    #   select_field(obj, field, choices, options = {})
    #
    # Creates a select tag for the specified field, which may be on an object.
    # The helper also creates the options elements inside the select tag for each
    # of the choices provided.
    #
    # Given a choices container of an array of strings the strings will be used for
    # the test and value of the options.
    # Given a container where the elements respond to first and last (such as a two-element array),
    # the “lasts” serve as option values and the “firsts” as option text.
    # Hashes are turned into this form automatically, so the keys become “firsts” and values become lasts.
    #
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will auto-select that options from the choices.
    #
    #   select_field :membership_type, ['Lifetime', '1 Month', '1 Year'] # =>
    #     <select name="membership_type" id="membership_type">
    #       <option value="Lifetime">Lifetime</option>
    #       <option value="1 Month">1 Month</option>
    #       <option value="1 Year">1 Year</option>
    #     </select>
    #
    #   select_field :membership_type, [['Lifetime', 1], ['1 Month', 2], ['1 Year', 3]] # =>
    #     <select name="membership_type" id="membership_type">
    #       <option value="1">Lifetime</option>
    #       <option value="2">1 Month</option>
    #       <option value="3">1 Year</option>
    #     </select>
    #
    #   select_field :membership_type, {'Lifetime' => 1, '1 Month' => 2, '1 Year' => 3} # =>
    #     <select name="membership_type" id="membership_type">
    #       <option value="1">Lifetime</option>
    #       <option value="2">1 Month</option>
    #       <option value="3">1 Year</option>
    #     </select>
    #
    #   # Where the @params[:membership_type] value is set already to "year"
    #   select_field :membership_type, {'Lifetime' => 'life', '1 Month' => 'month', '1 Year' => 'year'} # =>
    #     <select name="membership_type" id="membership_type">
    #       <option value="life">Lifetime</option>
    #       <option value="month">1 Month</option>
    #       <option value="year" selected="selected">1 Year</option>
    #     </select>
    #
    #   select_field :user, :membership_type, ['Lifetime', '1 Month', '1 Year'] # =>
    #     <select name="user[membership_type]" id="user_membership_type">
    #       <option value="Lifetime">Lifetime</option>
    #       <option value="1 Month">1 Month</option>
    #       <option value="1 Year">1 Year</option>
    #     </select>
    #
    #   @user = User.new(:membership_type => 'month')
    #   select_field :user, :membership_type, {'Lifetime' => 'life', '1 Month' => 'month', '1 Year' => 'year'} # =>
    #     <select name="user[membership_type]" id="user_membership_type">
    #       <option value="life">Lifetime</option>
    #       <option value="month" selected="selected">1 Month</option>
    #       <option value="year">1 Year</option>
    #     </select>
    #
    def select_field(*args)
      case args.size
      when 2
        options = {}
        choices = args.pop
        obj = args.shift
        field = nil
      else
        options = args.extract_options!.symbolize_keys
        choices = args.pop
        obj = args.shift
        field = args.shift
      end
      
      unless choices.is_a? Enumerable
        raise ArgumentError, 'the choices parameter must be an Enumerable object'
      end
      
      value = get_value(obj, field)
      
      content = choices.inject([]) { |opts, choice|
        text, opt_val = option_text_and_value(choice)
        opts << tag(:option, escape_once(text), {:value => escape_once(opt_val), :selected => (opt_val == value)})
      }.join("\n")
      
      tag :select, "\n#{content}\n", options.merge(get_id_and_name(obj, field))
    end
    
    # :call-seq:
    #   hidden_field(field, options = {})
    #   hidden_field(obj, field, options = {})
    #
    # Returns a hidden input for the specified field, which may be on an object.
    # If there is a value for the field in the request params or an object is
    # provided with that value set, it will auto-populate the input. If not
    # you should set the value with the <tt>:value</tt> option.
    #
    #   hidden_field :external_id, :value => 25 # =>
    #     <input type="hidden" name="external_id" id="external_id" value="25" />
    #
    #   # Where the @params[:external_id] value is set already to "247"
    #   hidden_field :external_id # =>
    #     <input type="hidden" name="external_id" id="external_id" value="247" />
    #
    #   hidden_field :user, :external_id, :value => 25 # =>
    #     <input type="hidden" name="user[external_id]" id="user_external_id" value="25" />
    #
    #   @user = User.new(:external_id => 247)
    #   hidden_field @user, :external_id # =>
    #     <input type="hidden" name="user[external_id]" id="user_external_id" value="247" />
    #
    def hidden_field(*args)
      input_tag 'hidden', *args
    end
    
    # Creats a standard open and close tags for the name provided with the content
    # and attributes supplied.
    #   tag :h2, "Sinatra Steps to the Stage", :title => "Applause" # =>
    #     <h1 title="Applause">Sinatra Steps to the Stage</h1>
    #
    def tag(name, content, options = {})
      "<#{name.to_s}#{tag_options(options)}>#{content}</#{name.to_s}>"
    end
    
    # Creates a self-closing/empty-element tag of the name specified.
    #   single_tag :img, :src => "/images/face.jpg" # =>
    #     <img src="/images/face.jpg" />
    #
    def single_tag(name, options = {})
      "<#{name.to_s}#{tag_options(options)} />"
    end
    
    private
    
    def escape_once(html) #:nodoc:
      html.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| HTML_ESCAPE[special] }
    end
    
    def input_tag(type, *args)
      obj, field, options = extract_options_and_field(*args)
      value = get_value(obj, field)
      case type.to_sym
      when :radio
        if options[:value].nil? || options[:value] =~ /^\s*$/
          raise ArgumentError, 'for radio inputs a value options must be provided'
        end
        options[:checked] = true if value == options[:value]
      when :checkbox
        if options[:value].nil? || options[:value] =~ /^\s*$/
          raise ArgumentError, 'for checkbox inputs a value options must be provided'
        end
        options[:checked] = "checked" if (value == options[:value] || (value.is_a?(Enumerable) && value.include?(options[:value])))
      else
        options[:value] = value unless value.blank?
      end
      single_tag :input, options.merge(:type => type).merge(get_id_and_name(obj, field))
    end
    
    def get_value(obj, field)
      if field.blank?
        @params[obj]
      else
        case obj
        when String, Symbol
          begin
            @params[obj][field]
          rescue NoMethodError
            nil
          end
        else
          obj.send(field.to_sym)
        end
      end
    end
    
    def get_id_and_name(obj, field)
      if field.blank?
        {:id => obj.to_s, :name => obj.to_s}
      else
        case obj
        when String, Symbol
          {:id => "#{obj}_#{field}", :name => "#{obj}[#{field}]"}
        else
          obj_name = obj.class.name.demodulize.underscore
          {:id => "#{obj_name}_#{field}", :name => "#{obj_name}[#{field}]"}
        end
      end
    end
    
    def option_text_and_value(option) #:nodoc:
      # Options are [text, value] pairs or strings used for both.
      if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:last)
        [option.first, option.last]
      else
        [option, option]
      end
    end
    
    def tag_options(options) #:nodoc:
      unless options.blank?
        attrs = []
        options.each_pair do |key, value|
          if BOOLEAN_ATTRIBUTES.include?(key)
            attrs << %(#{key}="#{key}") if value
          else
            attrs << %(#{key}="#{escape_once(value)}") if !value.nil?
          end
        end
        " #{attrs.sort * ' '}" unless attrs.empty?
      end
    end
    
    def extract_options_and_field(*args) #:nodoc:
      options = args.extract_options!.symbolize_keys
      obj = args.shift
      field = args.shift
      [obj, field, options]
    end
    
    def compute_public_path(source, dir, ext = nil) #:nodoc:
      source_ext = File.extname(source)[1..-1]
      if ext && source_ext.blank?
        source += ".#{ext}"
      end

      unless source =~ %r{^[-a-z]+://}
        source = "/#{dir}/#{source}" unless source[0] == ?/
      end

      return source
    end
    
  end
end

unless Array.method_defined?(:extract_options!)
  class Array #:nodoc:
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end
end
unless Hash.method_defined?(:symbolize_keys)
  class Hash #:nodoc:
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
end
