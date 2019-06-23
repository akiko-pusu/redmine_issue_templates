# frozen_string_literal: true

module LoginHelper
  def log_user(login, password)
    visit '/login'

    within('#login-form form') do
      fill_in 'username', with: login
      fill_in 'password', with: password
      find('input[name=login]').click
    end
  end

  def assign_template_priv(role, add_permission: nil, remove_permission: nil)
    return if add_permission.blank? && remove_permission.blank?

    role.add_permission! add_permission if add_permission.present?
    role.remove_permission! remove_permission if remove_permission.present?
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
