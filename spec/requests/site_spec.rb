require "spec_helper"

feature 'Site' do
  describe "As a developer I want to see the homepage so I know Monk is correctly installed" do
    scenario "A visitor goes to the homepage" do
      visit "/"
      page.should have_content("Hello, world!")
    end
  end
end
