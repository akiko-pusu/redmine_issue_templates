# Redmine Issue Template Plugin
#
# This is a plugin for Redmine to generate and use issue templates
# for each project to assist issue creation.
# Created by Akiko Takano.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

require 'redmine'
require 'issue_templates_issues_hook'
require 'issue_templates_projects_helper_patch'

Redmine::Plugin.register :redmine_issue_templates do
  name 'Redmine Issue Templates plugin'
  author 'Akiko Takano'
  description 'Plugin to generate and use issue templates for each project to assist issue creation.'
  version '0.1.4-dev'
  author_url 'http://twitter.com/akiko_pusu'
  requires_redmine version_or_higher: '2.5'
  url 'https://github.com/akiko-pusu/redmine_issue_templates'

  menu :admin_menu, :redmine_issue_templates, { controller: 'global_issue_templates', action: 'index', class: 'icon' },
       caption: :global_issue_templates, html: { class: 'icon' }

  project_module :issue_templates do
    permission :edit_issue_templates, issue_templates: [:new, :edit, :destroy, :move]
    permission :show_issue_templates, issue_templates: [:index, :show, :load, :set_pulldown, :list_templates]
    permission :manage_issue_templates,
               { issue_templates_settings: [:show, :edit] }, require: :member
  end

  Rails.configuration.to_prepare do
    require_dependency 'projects_helper'
    unless ProjectsHelper.included_modules.include? IssueTemplatesProjectsHelperPatch
      ProjectsHelper.send(:include, IssueTemplatesProjectsHelperPatch)
    end
  end
end
