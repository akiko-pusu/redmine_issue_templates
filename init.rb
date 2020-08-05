# frozen_string_literal: true

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
require 'issue_templates/journals_hook'

# NOTE: Keep error message for a while to support Redmine3.x users.
def issue_template_version_message(original_message = nil)
  <<-"USAGE"

  ==========================
  #{original_message}

  If you use Redmine3.x, please use Redmine Issue Templates version 0.2.x or clone via
  'v0.2.x-support-Redmine3' branch.
  You can download older version from here: https://github.com/akiko-pusu/redmine_issue_templates/releases
  ==========================
  USAGE
end

def template_menu_allowed?
  proc { |p| User.current.allowed_to?({ controller: 'issue_templates', action: 'show' }, p) }
end

Redmine::Plugin.register :redmine_issue_templates do
  begin
    name 'Redmine Issue Templates plugin'
    author 'Akiko Takano'
    description 'Plugin to generate and use issue templates for each project to assist issue creation.'
    version '1.1.0'
    author_url 'http://twitter.com/akiko_pusu'
    requires_redmine version_or_higher: '4.0'
    url 'https://github.com/akiko-pusu/redmine_issue_templates'

    settings partial: 'settings/redmine_issue_templates',
             default: {
               apply_global_template_to_all_projects: 'false',
               apply_template_when_edit_issue: 'false',
               enable_builtin_fields: 'false'
             }

    menu :admin_menu, :redmine_issue_templates, { controller: 'global_issue_templates', action: 'index' },
         caption: :global_issue_templates, html: { class: 'icon icon-global_issue_templates' }

    menu :project_menu, :issue_templates, { controller: 'issue_templates', action: 'index' },
         caption: :issue_templates, param: :project_id,
         after: :settings, if: template_menu_allowed?

    project_module :issue_templates do
      permission :edit_issue_templates, issue_templates: %i[new create edit update destroy move], note_templates: %i[new create edit update destroy move]
      permission :show_issue_templates, issue_templates: %i[index show load set_pulldown list_templates orphaned_templates],
                                        note_templates: %i[index show load list_templates]
      permission :manage_issue_templates, { issue_templates_settings: %i[index edit] }, require: :member
    end
  rescue ::Redmine::PluginRequirementError => e
    raise ::Redmine::PluginRequirementError.new(issue_template_version_message(e.message)) # rubocop:disable Style/RaiseArgs
  end
end
