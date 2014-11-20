require 'spec_helper'

feature 'User forgotten the password' do

  before(:each) do
    User.create(:email => "test@test.com", :password => 'test',
                :password_confirmation => 'test')
  end

  scenario 'request password reset' do
    visit '/sessions/new'
    expect(page).not_to have_content("Welcome, test@test.com")
    click_button "Forgotten password"
    expect(page).to have_content("Please enter your email and click reset!")
    fill_in 'email', :with => 'test@test.com'
    click_button "Reset"
    expect(page).to have_content("Email sent")
  end



end
