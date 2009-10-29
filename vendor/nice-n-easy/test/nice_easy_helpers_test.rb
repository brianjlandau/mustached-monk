require File.join(File.dirname(__FILE__), 'test_helper')

User = Struct.new(:email, :password, :picture, :bio, :gender, :subscribe, :external_id, :membership_type)

class NiceEasyHelpersTest < Test::Unit::TestCase
  include Sinatra::NiceEasyHelpers
  
  context 'link helper' do
    should 'create a link tag' do
      html = link("Go look at this", 'http://www.somewhere.com/')
      assert_select_in html, 'a[href="http://www.somewhere.com/"]', "Go look at this"
    end
    
    should 'create a link tag with custom HTML attributes' do
      html = link("Go look at this", 'http://www.somewhere.com/', :class => 'button')
      assert_select_in html, 'a.button[href="http://www.somewhere.com/"]', "Go look at this"
    end
  end
  
  context 'label helper' do
    should 'create a label tag without a field' do
      html = label(:email)
      assert_select_in html, 'label[for="email"]', 'Email'
    end
  
    should 'create a label tag with a field' do
      html = label(:user, :email)
      assert_select_in html, 'label[for="user_email"]', 'Email'
    end
  
    should 'create a label tag without a field with custom label' do
      html = label(:email, :text => 'Email Address')
      assert_select_in html, 'label[for="email"]', 'Email Address'
    end
  
    should 'create a label tag with a field with custom label' do
      html = label(:user, :email, :text => 'Email Address')
      assert_select_in html, 'label[for="user_email"]', 'Email Address'
    end
  end
  
  context 'text field helper' do
    setup do
      @params = {}
    end
    
    should 'create a input text tag without a field' do
      html = text_field(:email)
      assert_select_in html, 'input#email[type="text"][name="email"]'
    end
    
    should 'create a input text tag with a field' do
      html = text_field(:user, :email)
      assert_select_in html, 'input#user_email[type="text"][name=?]', "user[email]"
    end
    
    should 'create a text_field tag without a field with custom class' do
      html = text_field(:email, :class => 'required')
      assert_select_in html, 'input#email.required[type="text"][name="email"]'
    end
    
    should 'create a text_field tag with a field with custom class' do
      html = text_field(:user, :email, :class => 'required')
      assert_select_in html, 'input#user_email.required[type="text"][name=?]', 'user[email]'
    end
    
    should 'create a text_field tag with value set by params when no field provided' do
      @params = {:email => 'joe@example.com'}.with_indifferent_access
      html = text_field(:email)
      assert_select_in html, 'input#email[type="text"][name="email"][value="joe@example.com"]'
    end
    
    should 'create a text_field tag with value set by params' do
      @params = {:user => {:email => 'joe@example.com'}.with_indifferent_access}.with_indifferent_access
      html = text_field(:user, :email)
      assert_select_in html, 'input#user_email[type="text"][name=?][value="joe@example.com"]', 'user[email]'
    end
    
    should 'create a text_field tag with value set by object when provided' do
      user = User.new
      user.email = "joe@example.com"
    
      html = text_field(user, :email)
      assert_select_in html, 'input#user_email[type="text"][name=?][value="joe@example.com"]', 'user[email]'
    end
    
    teardown do
      @param = nil
    end
  end
  
  context 'text area helper' do
    setup do
      @params = {}
    end

    should 'create a text area tag without a field' do
      html = text_area(:bio)
      assert_select_in html, 'textarea#bio[name="bio"]'
    end

    should 'create a text area tag with a field' do
      html = text_area(:user, :bio)
      assert_select_in html, 'textarea#user_bio[name=?]', 'user[bio]'
    end

    should 'create a text area tag without a field with custom class' do
      html = text_area(:bio, :class => 'required')
      assert_select_in html, 'textarea#bio.required[name="bio"]'
    end

    should 'create a text area tag with a field with custom class' do
      html = text_area(:user, :bio, :class => 'required')
      assert_select_in html, 'textarea#user_bio.required[name=?]', 'user[bio]'
    end

    should 'create a text area tag with value set by params when no field provided' do
      @params = {:bio => %q(I'm from Canada)}.with_indifferent_access
      html = text_area(:bio)
      assert_select_in html, 'textarea#bio[name="bio"]', %q(I'm from Canada)
    end

    should 'create a text area tag with value set by params' do
      @params = {:user => {:bio => %q(I'm from Canada)}.with_indifferent_access}.with_indifferent_access
      html = text_area(:user, :bio)
      assert_select_in html, 'textarea#user_bio', %q(I'm from Canada)
    end

    should 'create a text area tag with value set by object when provided' do
      user = User.new
      user.bio = %q(I'm from Canada)

      html = text_area(user, :bio)
      assert_select_in html, 'textarea#user_bio', %q(I'm from Canada)
    end

    teardown do
      @params = nil
    end
  end

  context 'password field helper' do
    setup do
      @params = {}
    end

    should 'create a input password tag without a field' do
      html = password_field(:password)
      assert_select_in html, 'input#password[type="password"][name="password"]'
    end

    should 'create a input password tag with a field' do
      html = password_field(:user, :password)
      assert_select_in html, 'input#user_password[type="password"][name=?]', 'user[password]'
    end

    should 'create a password field tag without a field with custom class' do
      html = password_field(:password, :class => 'required')
      assert_select_in html, 'input#password.required[type="password"][name="password"]'
    end

    should 'create a password field tag with a field with custom class' do
      html = password_field(:user, :password, :class => 'required')
      assert_select_in html, 'input#user_password.required[type="password"][name=?]', 'user[password]'
    end

    should 'create a password field tag with value set by params when no field provided' do
      @params = {:password => 'password'}.with_indifferent_access
      html = password_field(:password)
      assert_select_in html, 'input#password[type="password"][name="password"][value="password"]'
    end

    should 'create a password field tag with value set by params' do
      @params = {:user => {:password => 'password'}.with_indifferent_access}.with_indifferent_access
      html = password_field(:user, :password)
      assert_select_in html, 'input#user_password[type="password"][name=?][value="password"]', 'user[password]'
    end

    should 'create a password_field tag with value set by object when provided' do
      user = User.new
      user.password = "password"

      html = password_field(user, :password)
      assert_select_in html, 'input#user_password[type="password"][name=?][value="password"]', 'user[password]'
    end

    teardown do
      @param = nil
    end
  end

  context 'file field helper' do
    setup do
      @params = {}
    end
    
    should 'create a input text tag without a field' do
      html = file_field(:picture)
      assert_select_in html, 'input#picture[type="file"][name="picture"]'
    end

    should 'create a input text tag with a field' do
      html = file_field(:user, :picture)
      assert_select_in html, 'input#user_picture[type="file"][name=?]', 'user[picture]'
    end

    should 'create a file_field tag without a field with custom class' do
      html = file_field(:picture, :class => 'required')
      assert_select_in html, 'input#picture.required[type="file"][name="picture"]'
    end

    should 'create a file_field tag with a field with custom class' do
      html = file_field(:user, :picture, :class => 'required')
      assert_select_in html, 'input#user_picture.required[type="file"][name=?]', 'user[picture]'
    end
    
    teardown do
      @param = nil
    end
  end

  context 'button helper' do
    should 'create a button element of submit type' do
      html = button('save', 'Save and continue')
      assert_select_in html, 'button#save[type="submit"][name="save"]', 'Save and continue'
    end

    should 'create a button element of submit type with a custom class' do
      html = button('save', 'Save and continue', :class => 'light')
      assert_select_in html, 'button#save.light[type="submit"][name="save"]', 'Save and continue'
    end


    should 'create a button element of submit type with a value' do
      html = button('save', 'Save and continue', :value => 'continue')
      assert_select_in html, 'button#save[type="submit"][name="save"][value="continue"]', 'Save and continue'
    end

    should 'create a button element of button type' do
      html = button('action', 'Do something', 'button')
      assert_select_in html, 'button#action[type="button"][name="action"]', 'Do something'
    end

    should 'create a button element of button type with custom class' do
      html = button('action', 'Do something', 'button', :class => 'light')
      assert_select_in html, 'button#action.light[type="button"][name="action"]', 'Do something'
    end
  end

  context 'image submit button helper' do
    should 'create an image input tag' do
      html = image_input('save.png')
      assert_select_in html, 'input[type="image"][src="/images/save.png"]'
    end

    should 'create an image input tag with custom class' do
      html = image_input('save.png', :class => 'large')
      assert_select_in html, 'input.large[type="image"][src="/images/save.png"]'
    end
  end

  context 'submit helper' do
    should 'create a submit button' do
      html = submit
      assert_select_in html, 'input[type="submit"][value="Save"]'
    end

    should 'create a sbumit button with custom text' do
      html = submit('Continue')
      assert_select_in html, 'input[type="submit"][value="Continue"]'
    end

    should 'create a sbumit button with custom text and custom class' do
      html = submit('Continue', :class => 'large')
      assert_select_in html, 'input.large[type="submit"][value="Continue"]'
    end
  end

  context 'hidden field helper' do
    setup do
      @params = {}
    end

    should 'create a input hidden tag without a field' do
      html = hidden_field(:external_id, :value => 25)
      assert_select_in html, 'input#external_id[type="hidden"][name="external_id"][value="25"]'
    end

    should 'create a input hidden tag with a field' do
      html = hidden_field(:user, :external_id, :value => 25)
      assert_select_in html, 'input#user_external_id[type="hidden"][name=?][value="25"]', 'user[external_id]'
    end

    should 'create a hidden field tag without a field with custom class' do
      html = hidden_field(:external_id, :class => 'required', :value => 25)
      assert_select_in html, 'input#external_id.required[type="hidden"][name="external_id"][value="25"]'
    end

    should 'create a hidden field tag with a field with custom class' do
      html = hidden_field(:user, :external_id, :class => 'required', :value => 25)
      assert_select_in html, 'input#user_external_id.required[type="hidden"][name=?][value="25"]', 'user[external_id]'
    end

    should 'create a hidden field tag with value set by params when no field provided' do
      @params = {:external_id => '3987'}.with_indifferent_access
      html = hidden_field(:external_id)
      assert_select_in html, 'input#external_id[type="hidden"][name="external_id"][value="3987"]'
    end

    should 'create a hidden field tag with value set by params' do
      @params = {:user => {:external_id => '3987'}.with_indifferent_access}.with_indifferent_access
      html = hidden_field(:user, :external_id)
      assert_select_in html, 'input#user_external_id[type="hidden"][name=?][value="3987"]', 'user[external_id]'
    end

    should 'create a hidden field tag with value set by object when provided' do
      user = User.new
      user.external_id = "3987"

      html = hidden_field(user, :external_id)
      assert_select_in html, 'input#user_external_id[type="hidden"][name=?][value="3987"]', 'user[external_id]'
    end

    teardown do
      @param = nil
    end
  end

  context 'checkbox field helper' do
    setup do
      @params = {}
    end

    should 'create a input checkbox tag without a field' do
      html = checkbox_field(:subscribe, :value => 1)
      assert_select_in html, 'input#subscribe[type="checkbox"][name="subscribe"][value="1"]'
    end
    
    should 'require a value option' do
      assert_raise ArgumentError do
        checkbox_field(:subscribe)
      end
    end

    should 'create a input checkbox tag with a field' do
      html = checkbox_field(:user, :subscribe, :value => 1)
      assert_select_in html, 'input#user_subscribe[type="checkbox"][name=?][value="1"]', 'user[subscribe]'
    end

    should 'create a checkbox field tag without a field with custom class' do
      html = checkbox_field(:subscribe, :value => 1, :class => 'required')
      assert_select_in html, 'input#subscribe.required[type="checkbox"][name="subscribe"][value="1"]'
    end

    should 'create a checkbox field tag with a field with custom class' do
      html = checkbox_field(:user, :subscribe, :value => 1, :class => 'required')
      assert_select_in html, 'input#user_subscribe.required[type="checkbox"][name=?][value="1"]', 'user[subscribe]'
    end

    should 'create a checkbox field tag with checked set by params when no field provided' do
      @params = {:subscribe => 1}.with_indifferent_access
      html = checkbox_field(:subscribe, :value => 1)
      assert_select_in html, 'input#subscribe[type="checkbox"][name="subscribe"][value="1"][checked="checked"]'
    end

    should 'create a checkbox field tag with checked not set when value does not match' do
      @params = {:subscribe => 2}.with_indifferent_access
      html = checkbox_field(:subscribe, :value => 1)
      assert_select_in html, 'input#subscribe[type="checkbox"][name="subscribe"][value="1"]:not([checked])'
    end

    should 'create a checkbox field tag with checked set by params' do
      @params = {:user => {:subscribe => 1}.with_indifferent_access}.with_indifferent_access
      html = checkbox_field(:user, :subscribe, :value => 1)
      assert_select_in html, 'input#user_subscribe[type="checkbox"][name=?][value="1"][checked="checked"]', 'user[subscribe]'
    end

    should 'create a checkbox field tag with checked set by object when provided' do
      user = User.new
      user.subscribe = 1

      html = checkbox_field(user, :subscribe, :value => 1)
      assert_select_in html, 'input#user_subscribe[type="checkbox"][name=?][value="1"][checked="checked"]', 'user[subscribe]'
    end
    
    context 'multipe values possilbe' do
      setup do
        @params = {:user => {:subscribe => ['newsletter']}.with_indifferent_access}.with_indifferent_access
      end
      
      should 'craete a checkbox field tag with checked set if value is in param values' do
        html = checkbox_field(:user, :subscribe, :value => 'newsletter')
        assert_select_in html, 'input#user_subscribe[type="checkbox"][name=?][value="newsletter"][checked="checked"]', 'user[subscribe]'
      end
      
      should 'craete a checkbox field tag with checked not set if value is not in param values' do
        html = checkbox_field(:user, :subscribe, :value => 'updates')
        assert_select_in html, 'input#user_subscribe[type="checkbox"][name=?][value="updates"]:not([checked])', 'user[subscribe]'
      end
    end

    teardown do
      @param = nil
    end
  end
  
  
  context 'radio button helper' do
    setup do
      @params = {}
    end

    should 'create a input radio tag without a field' do
      html = radio_button(:gender, :value => 'male')
      assert_select_in html, 'input#gender[type="radio"][name="gender"][value="male"]'
    end
    
    should 'require a value option' do
      assert_raise ArgumentError do
        radio_button(:gender)
      end
    end

    should 'create a input radio tag with a field' do
      html = radio_button(:user, :gender, :value => 'male')
      assert_select_in html, 'input#user_gender[type="radio"][name=?][value="male"]', 'user[gender]'
    end

    should 'create a radio field tag without a field with custom class' do
      html = radio_button(:gender, :value => "male", :class => 'required')
      assert_select_in html, 'input#gender.required[type="radio"][name="gender"][value="male"]'
    end

    should 'create a radio field tag with a field with custom class' do
      html = radio_button(:user, :gender, :value => "male", :class => 'required')
      assert_select_in html, 'input#user_gender.required[type="radio"][name=?][value="male"]', 'user[gender]'
    end

    should 'create a radio field tag with checked set by params when no field provided' do
      @params = {:gender => "male"}.with_indifferent_access
      html = radio_button(:gender, :value => "male")
      assert_select_in html, 'input#gender[type="radio"][name="gender"][value="male"][checked="checked"]'
    end

    should 'create a radio field tag with checked not set when value does not match' do
      @params = {:gender => 'female'}.with_indifferent_access
      html = radio_button(:gender, :value => "male")
      assert_select_in html, 'input#gender[type="radio"][name="gender"][value="male"]:not([checked])'
    end

    should 'create a radio field tag with checked set by params' do
      @params = {:user => {:gender => "male"}.with_indifferent_access}.with_indifferent_access
      html = radio_button(:user, :gender, :value => "male")
      assert_select_in html, 'input#user_gender[type="radio"][name=?][value="male"][checked="checked"]', 'user[gender]'
    end

    should 'create a radio field tag with checked set by object when provided' do
      user = User.new
      user.gender = "male"

      html = radio_button(user, :gender, :value => "male")
      assert_select_in html, 'input#user_gender[type="radio"][name=?][value="male"][checked="checked"]', 'user[gender]'
    end

    teardown do
      @param = nil
    end
  end
  
  context 'select field helper' do
    setup do
      @params = {}
    end
    
    should 'require an items argument' do
      assert_raise ArgumentError do
        select_field(:membership_type)
      end
    end
    
    should 'create a select tag with options' do
      html = select_field(:membership_type, ['Lifetime', '1 Month', '1 Year'])
      
      assert_select_in html, 'select#membership_type[name="membership_type"]'
      assert_select_in html, 'select#membership_type > option', 'Lifetime'
      assert_select_in html, 'select#membership_type > option', '1 Month'
      assert_select_in html, 'select#membership_type > option', '1 Year'
    end
    
    should 'create a select tag with options from an array of arrays' do
      html = select_field(:membership_type, [['Lifetime', 1], ['1 Month', 2], ['1 Year', 3]])
      
      assert_select_in html, 'select#membership_type[name="membership_type"]'
      assert_select_in html, 'select#membership_type > option[value="1"]', 'Lifetime'
      assert_select_in html, 'select#membership_type > option[value="2"]', '1 Month'
      assert_select_in html, 'select#membership_type > option[value="3"]', '1 Year'
    end
    
    should 'create a select tag with options from a hash' do
      html = select_field(:membership_type, {'Lifetime' => 1, '1 Month' => 2, '1 Year' => 3})
      
      assert_select_in html, 'select#membership_type[name="membership_type"]'
      assert_select_in html, 'select#membership_type > option[value="1"]', 'Lifetime'
      assert_select_in html, 'select#membership_type > option[value="2"]', '1 Month'
      assert_select_in html, 'select#membership_type > option[value="3"]', '1 Year'
    end
    
    should 'create a select tag with object and field' do
      html = select_field(:user, :membership_type, ['Lifetime', '1 Month', '1 Year'])
      assert_select_in html, 'select#user_membership_type[name=?]', 'user[membership_type]'
    end
    
    should 'create a select tag with custom class' do
      html = select_field(:membership_type, ['Lifetime', '1 Month', '1 Year'], :class => 'required')
      assert_select_in html, 'select#membership_type.required[name="membership_type"]'
    end
    
    should 'create a select tag with object and field with custom class' do
      html = select_field(:user, :membership_type, ['Lifetime', '1 Month', '1 Year'], :class => 'required')
      assert_select_in html, 'select#user_membership_type.required[name=?]', 'user[membership_type]'
    end
    
    should 'create a select tag with value from params' do
      @params = {:membership_type => '1 Year'}.with_indifferent_access
      html = select_field(:membership_type, ['Lifetime', '1 Month', '1 Year'])
      assert_select_in html, 'select#membership_type[name="membership_type"] > option[selected="selected"]', '1 Year'
    end
    
    should 'create a select tag with object and field with value from params' do
      @params = {:user => {:membership_type => '1 Year'}.with_indifferent_access}.with_indifferent_access
      html = select_field(:user, :membership_type, ['Lifetime', '1 Month', '1 Year'])
      assert_select_in html, 'select#user_membership_type > option[selected="selected"]', '1 Year'
    end
    
    should 'create a select tag with object and field with value from object' do
      user = User.new
      user.membership_type = '1 Year'
      
      html = select_field(user, :membership_type, ['Lifetime', '1 Month', '1 Year'])
      assert_select_in html, 'select#user_membership_type > option[selected="selected"]', '1 Year'
    end
    
    teardown do
      @param = nil
    end
  end
  
  context 'image tag helper' do
    should 'create an image tag for an image in the standard location' do
      html = image_tag('button.jpg')
      assert_select_in html, 'img[src="/images/button.jpg"]'
    end
    
    should 'create an image tag for an image in the standard location with options' do
      html = image_tag('button.jpg', :alt => 'Action', :class => 'rounded')
      assert_select_in html, 'img.rounded[src="/images/button.jpg"][alt="Action"]'
    end
    
    should 'create an image tag for an image in a custom location' do
      html = image_tag('/icons/button.jpg')
      assert_select_in html, 'img[src="/icons/button.jpg"]'
    end
    
    should 'create an image tag for an image on another server' do
      html = image_tag('http://www.example.com/buttons/close.jpg')
      assert_select_in html, 'img[src="http://www.example.com/buttons/close.jpg"]'
    end
  end
  
  context 'javascript include tag helper' do
    should 'create a script tag for a javascript file in the standard location' do
      html = javascript_include_tag('jquery')
      assert_select_in html, 'script[src="/javascripts/jquery.js"]'
    end
    
    should 'create multiple script tags for javascript files in multiple locations' do
      html = javascript_include_tag('jquery', 'facebox')
      assert_select_in html, 'script[src="/javascripts/jquery.js"]'
      assert_select_in html, 'script[src="/javascripts/facebox.js"]'
    end
    
    should 'create a script tag for a javascript file in a custom location' do
      html = javascript_include_tag('/scripts/custom.js')
      assert_select_in html, 'script[src="/scripts/custom.js"]'
    end
    
    should 'create a script tag for a javascript file on another server' do
      html = javascript_include_tag('http://www.example.com/js/prototype.js')
      assert_select_in html, 'script[src="http://www.example.com/js/prototype.js"]'
    end
  end
  
  context 'stylesheet link tag helper' do
    should 'create a link tag for a stylesheet file in the standard location' do
      html = stylesheet_link_tag('global')
      assert_select_in html, 'link[href="/stylesheets/global.css"][rel="stylesheet"][type="text/css"][media="screen"]'
    end
    
    should 'create a link tag for a stylesheet file in the standard location with media attribute' do
      html = stylesheet_link_tag('print', :media => 'print')
      assert_select_in html, 'link[href="/stylesheets/print.css"][rel="stylesheet"][type="text/css"][media="print"]'
    end
    
    should 'create multiple link tags for stylesheet files in multiple locations' do
      html = stylesheet_link_tag('global', 'print')
      assert_select_in html, 'link[href="/stylesheets/global.css"][rel="stylesheet"][type="text/css"]'
      assert_select_in html, 'link[href="/stylesheets/print.css"][rel="stylesheet"][type="text/css"]'
    end
    
    should 'create a link tag for a stylesheet file in a custom location' do
      html = stylesheet_link_tag('/styles/custom.css')
      assert_select_in html, 'link[href="/styles/custom.css"][rel="stylesheet"][type="text/css"][media="screen"]'
    end
    
    should 'create a link tag for a stylesheet file on another server' do
      html = stylesheet_link_tag('http://www.example.com/css/sample.css')
      assert_select_in html, 'link[href="http://www.example.com/css/sample.css"][rel="stylesheet"][type="text/css"][media="screen"]'
    end
  end

end
