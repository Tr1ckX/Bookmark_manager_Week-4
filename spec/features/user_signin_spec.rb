require 'spec_helper'

feature "User signs in" do

  before(:each) do
    User.create(:email => "test@test.com", :password => 'test',
                :password_confirmation => 'test')
  end

  scenario "with corret credentials" do
    visit '/sessions/new'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    # save_and_open_page
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end

end
