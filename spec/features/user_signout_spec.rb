require 'spec_helper'

feature 'User signs out' do

  before(:each) do
    User.create(:email => "test@test.com", :password => "test",
                :password_confirmation => 'test')
  end

  scenario 'while being signd in' do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!")
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end
