require File.dirname(__FILE__) + '/spec_helper'

describe "Form Builder" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end


  context "edit form" do
    it "should be have hidden method of PUT" do
      text_drop = get_drop @@text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor text %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'text' => text_drop)
    end
  end

  context "when selecting an alternate method" do
    it "should post to that method" do
      text_drop = get_drop @@text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '/no_no_no"></form>'
      template = '{% formfor text post_method:no_no_no %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'text' => text_drop)
    end
  end


  context "when using a form_* item" do
    it "should produce data based on form type" do
      user_drop = get_drop @@user_default_values
      expected = '<form method="POST" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><br/><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + user_drop.login + '"/></form>'
      template = '{% formfor liquid_demo_model %}<br/>{{ form_login }}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'liquid_demo_model' => user_drop)
    end

    it "should dynamically create an input box" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><input type="text" id="liquid_demo_model_drop[name]" name="liquid_demo_model_drop[name]" value="My Name"/></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{{ form_name }}{% endformfor %}'
      template.should parse_to(expected)
    end    
  end

  context "edit form" do
    it "should allow you to apply a css class" do
      user_drop = get_drop @@user_default_values
      expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => user_drop)
    end
  end

  context "when creating form items outside of the form" do
    specify "they should be out of the form's scope and be ignored" do
      user_drop = get_drop @@user_default_values
      expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor user class:tester %}{% endformfor %}{{form_login}}'
      template.should parse_with_atributes_to(expected, 'user' => user_drop)
    end
  end


  context "when building form for nested route" do
    before(:each) do
      @child_drop = get_drop @@text_content_default_values
      @parent_drop = get_drop @@text_content_default_values.merge({ :record_id => 2, :name => 'parent' })
    end

    it "should be created with valid route" do
      expected = '<form method="POST" action="' + (object_url @parent_drop) + (object_url @child_drop)  + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = "{% nested_formfor parent child %}{% endnested_formfor %}"
      template.should parse_with_atributes_to(expected, 'child' => @child_drop, 'parent' => @parent_drop)
    end

    it "should allow elements that refer to both the parent and the child" do
      expected = '<form method="POST" action="' + (object_url @parent_drop) + (object_url @child_drop)  + '"><input type="hidden" name="_method" value="PUT"/><input type="text" id="liquid_demo_model[name]" name="liquid_demo_model[name]" value="Basic Essay Here"/><input type="text" id="liquid_demo_model[name]" name="liquid_demo_model[name]" value="parent"/></form>'
      template = "{% nested_formfor parent child %}{{ form_name }}{{ parent_form_name }}{% endnested_formfor %}"
      template.should parse_with_atributes_to(expected, 'child' => @child_drop, 'parent' => @parent_drop)
    end  
  end


  context "when a form has errors" do
    before(:each) do
  '    model = mock_model Spec::Mocks::Mock, @@user_default_values
      model.stub!(:errors).and_return(ActiveRecord::Errors.new(model))
      @user_drop = model
      def @user_drop.to_liquid
        @user_drop
      end
      def @user_drop.dropped_class
        "User"
      end
   '
      @user_drop = get_drop @@user_default_values
      @user_drop.stub!(:errors).and_return(ActiveRecord::Errors.new(@user_drop))
    end

    it "should show generic error for drop" do
      @user_drop.errors.add("error")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>1 error(s) occurred while processing information</h2><ul><li>error - is invalid</li></ul></div></form>'
      template = '{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end

    it "should show error around relevant form item" do
      @user_drop.errors.add("login", "login already used")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>1 error(s) occurred while processing information</h2><ul><li>login - login already used</li></ul></div><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + @user_drop[:login] + '" class="error-item"/></form>'
      template = '{% formfor user class:tester %}{{ form_login }}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end

    it "should show multiple errors for multiple categories" do
      @user_drop.errors.add("error")
      @user_drop.errors.add("login", "login already used")
      @user_drop.errors.add("login", "login too short")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>3 error(s) occurred while processing information</h2><ul><li>login - login already used</li><li>login - login too short</li><li>error - is invalid</li></ul></div><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + @user_drop[:login] + '" class="error-item"/></form>'
      template = '{% formfor user class:tester %}{{ form_login }}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end
  end

end