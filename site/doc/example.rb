require 'spec'

context 'domain based web testing example' do
  specify 'basic' do
    # START basic
    login_page = LoginPage.new(@browser)
    login_page.username_field.type('user')
    login_page.password_field.type('password')
    login_page.login_button.click
    # END basic
  end

  specify 'login' do
    # START login
    login_page = LoginPage.new(@browser)
    login_page.login('user', 'wrongpassword')
    work_items_page = WorkItemsPage.new(@browser)
    work_item_page.fill_in(data_fixture.create_full_work_item_data)
    work_item_page.due_date_field.fill_in_as_yesterday
    work_item_page.submit_buttoc.click
    work_item_page.should_be_present
    work_item_page.error.should_be_visible
    work_item_page.error.text.should == 'Due date should be after today'
    # END login
  end
end

# START check
class CommentCheckBox
  attr_reader :browser, :locator

  def initialize(browser, locator, comment_span)
    @browser = browser
    @locator = locator
    @comment_span = comment_span
  end

  def selected
    browser.get_value(locator) == 'on'
  end

  def click
    old_value = selected
    browser.wait_for_condition(@comment_span.script_check_visible(not old_value), 5000)
  end
end
# END check