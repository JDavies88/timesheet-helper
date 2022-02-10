# frozen_string_literal: true

require 'webdrivers'
require 'yaml'

creds = YAML.load_file('creds.yml')
timesheet = YAML.load_file('timeSheet.yml')

options = Selenium::WebDriver::Chrome::Options.new(detach: true)
driver = Selenium::WebDriver.for :chrome, capabilities: options

driver.manage.timeouts.implicit_wait = 5_000

driver.get 'https://dvla.service-now.com'

# Log in

driver.switch_to.frame driver.find_element(id: 'gsft_main')

username_box = driver.find_element(id: 'user_name')
username_box.send_keys creds['user_name'], :tab

password_box = driver.find_element(id: 'user_password')
password_box.send_keys creds['user_password'], :tab

login_button = driver.find_element(id: 'sysverb_login')
login_button.click

begin
  alert = driver.switch_to.alert
  alert.dismiss
rescue
end

# Navigate to new timesheet
pending = driver.find_element(link_text: 'Pending')
pending.click

driver.switch_to.frame driver.find_element(id: 'gsft_main')
new = driver.find_element(id: 'sysverb_new')
new.click

# Create timesheet
week_start = driver.find_element(id: 'time_sheet.week_starts_on')
week_start.send_keys timesheet['date'], :tab

save = driver.find_element(id: 'sysverb_insert_and_stay')
save.click

# Create time cards

timesheet['time_cards'].each do |time_card|
  new = driver.find_element(id: 'sysverb_new')
  new.click

  # Project Area
  project_area = driver.find_element(id: 'sys_display.time_card.u_booking_code')
  project_area.send_keys time_card['project_area'], :tab

  # Project Area
  l2_role = driver.find_element(id: 'sys_display.time_card.u_phase')
  l2_role.send_keys time_card['phase'], :tab

  # Phase
  unless time_card['l2_role'].nil?
    sleep(1)
    phase = driver.find_element(id: 'sys_display.time_card.u_level2')
    phase.send_keys time_card['l2_role'], :tab
  end

  # Days
  time_card['days'].each do |day|
    field = driver.find_element(id: "time_card.#{day}")
    field.send_keys '7.4', :tab
  end

  save = driver.find_element(id: 'sysverb_insert_and_stay')
  save.click

  update = driver.find_element(id: 'sysverb_update')
  update.click
end
