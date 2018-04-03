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
require 'issue_templates/issues_hook'
require 'issue_templates/projects_helper_patch'

Redmine::Plugin.register :redmine_issue_templates do
  name 'Redmine Issue Templates plugin'
  author 'Akiko Takano'
  description 'Plugin to generate and use issue templates for each project to assist issue creation.'
  version '0.1.9'
  author_url 'http://twitter.com/akiko_pusu'
  requires_redmine version_or_higher: '3.0'
  url 'https://github.com/akiko-pusu/redmine_issue_templates'

  settings partial: 'settings/redmine_issue_templates',
           default: {
             'apply_global_template_to_all_projects' => 'false'
           }

  menu :admin_menu, :redmine_issue_templates, { controller: 'global_issue_templates', action: 'index' },
       caption: :global_issue_templates, html: { class: 'icon icon-global_issue_templates' }

  project_module :issue_templates do
    permission :edit_issue_templates, issue_templates: [:new, :edit, :update, :destroy, :move]
    permission :show_issue_templates,
               issue_templates: [:index, :show, :load, :set_pulldown, :list_templates, :orphaned_templates]
    permission :manage_issue_templates,
               { issue_templates_settings: [:show, :edit] }, require: :member
  end

  Rails.configuration.to_prepare do
    require_dependency 'projects_helper'
    unless ProjectsHelper.included_modules.include? IssueTemplates::ProjectsHelperPatch
      ProjectsHelper.send(:include, IssueTemplates::ProjectsHelperPatch)
    end
  end
end
