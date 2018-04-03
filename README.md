# Redmine Issue Templates Plugin

Plugin to generate and use issue templates for each project to assist issue
creation. For Redmine 2.1.x or higher, please use version 0.0.4 or higher. For
Redmine 2.0, please use version 0.0.3 or higher.

Build Status: [![CircleCI](https://circleci.com/gh/akiko-pusu/redmine_issue_templates.svg?style=svg)](https://circleci.com/gh/akiko-pusu/redmine_issue_templates)

### Repository

*   https://github.com/akiko-pusu/redmine_issue_templates
*   https://bitbucket.org/akiko_pusu/redmine_issue_templates (Obsoleted)


### Plugin installation

1.  Copy the plugin directory into the $REDMINE_ROOT/plugins directory. Please
    note that plugin's folder name should be "redmine_issue_templates". If
    changed, some migration task will be failed.
2.  Do migration task.

    e.g. rake redmine:plugins:migrate RAILS_ENV=production

1.  (Re)Start Redmine.


### Uninstall

Try this:

*   rake db:migrate_plugins NAME=redmine_issue_templates VERSION=0
    RAILS_ENV=production


See also:
http://www.r-labs.org/projects/issue-template/wiki/About_en#Uninstall-plugin

### Required Settings

1.  Login to your Redmine install as an Administrator
2.  Enable the permissions for your Roles.

    Show issue templates: User can show issue templates and use templates when
    creating/updating issues. Edit issue templates: User can
    create/update/activate templates for each project. Manage issue templates:
    User can edit help message of templates for each project.

3.  Enable the module "Issue Template" on the project setting page.
4.  The link to the plugin should appear on that project's navigation.


### Note

This plugin aims to assist contributor's feedback by using template if the
project has some format for issues.

### Troubleshoot for bundle intall and startup problem

This plugin repository includes some test code and gem settiing. If you have
some trouble related "bundle intall", please try --without option.

    Exp. bundle install --without test

### WebPage

* https://www.redmine.org/plugins/redmine_issue_templates (Redmine Plugin List)
* http://www.r-labs.org/projects/issue-template (Project Page)


### Description and usage info

*   http://www.r-labs.org/projects/issue-template/wiki/About_en


## Changelog

### 0.1.9

Bugfix and refactoring release.

* Bugfix: Fix wrong template sort ordering.  (GitHub: #174)
* Change UI to reorder templates with using drag and drop.
* Add feature to copy template (Now project scope template only.)
* Code refactoring. Use Headless Chrome for feature spec. Change to use CircleCI for build and test.
* PR: Update Bulgarian translation. Thank you so much, Ivan Cenov! (GitHub: #171)
* PR: Update Update pt-BR.yml Thank you so much, Adriano Baptistella! (GitHub: #173)
* Bugfix: Wrong column label in "Preview Template Contents" modal dialog. (GitHub: #154)
* PR: Updates to German language file. Thank you so much, Tobias Fischer! (GitHub: #164)

### 0.1.8

Bugfix release.

* Bugfix: Prevent "undefined local variable or method" error when listing project orphaned templates. (GitHub: #150)
* PR: Add Portuguese translation. Thank you so much, Adriano Baptistella! (GitHub: #149)
* Change url of Redmine Plugin Directory. (Changed identifier from issue_templates to redmine_issue_templates.)


### 0.1.7

Bugfix release, and some code refactorings.

#### Bugfix:

* After related tracker is removed, index (list) templates failed with exception. (#139)
* Checklist not loading from Template. (#141)

#### Refactoring:

* Remove all unlodable statement.
* Remove unused rake task.
* Rename modules.


### 0.1.6

Maintenance release to follow Redmine's update, and some refactoring related to test, namespace.
Other additional updates are following:

* Change support Redmine version to 3.0 or higher.
* Stop to use jbuilder for rendering json. (#124)
    * Now any gemfile is not used.
* PR: UI improvement / Correct CSS. Thanks taqueci! (#120, #123)
* Bugfix: Add exception handler and not to work rake task if rake task name is not specified. (#130)
* Logging if template is deleted. (#118)
* Change Template UI related to delete action. (#117)
    * Prevent unexpected deletion of template.
* PR: Add to confirm before replacing description and subject. Thanks, Tatsuya Saito. (#111)
* PR: Fix CSS setting. Thanks, Tatsuya Saito. (#110)
* Updated Simplified Chinese translation, thanks Steven.W. (#105, #113)

### 0.1.5

NOTE: Please run "rake redmine:plugins:migrate" task because new column is added.

#### Feature for Global issue templates

* Add feature enabled to  mark global issue template as "default".
* Add plugin setting option to apply global issue templates to all the project.
    * This option is on the plugin configuration screen. Please read help content before activate this option!

#### Other updates

* Update Russian translation. Thanks danaivehr! (GitHub: #95)
* Prevent to locate template pulldown above "tracker" field and soon after jump below "tracker" field. (GitHub: #96)
* Unselect projects on global issue template edit screen does not work correctly. (GitHub: #99)
* Feature: Add “Revert” Icon to revert applied template. (Github: #98)
* Change the place of message to notice "default template loaded" now to bottom of the page.
* Change the place of "Check all | Uncheck all” link in global issue template create / edit screen, to above the project list. (GitHub: #90)
    * In case the list of projects is very long and would be much more comfortable to have the option on top.
* Project select checkbox area is collapsed by default.
    * Also, in case the list of projects is very long, administrator has to scroll to submit "Save" button.

### 0.1.4.1

Bugfix version for #83, #92. Correct some methods not to use named parameters,
because ruby 1.9x does not support named parameters.

* Bugfix: GitHub: #83, #92
* Bug: Italian translation should be start with "it". (GitHub: #87)

### 0.1.4

Maintenance release to follow Redmine's update, and some refactoring related to test, namespace.
Other additional updates are following:

*   Change css and default width setting for template filter modal dialog. (GitHub: #78)
*   Add Italian translation. Thank you so much, Luca Lesinigo! (GitHub: #75)
*   Add Danish translation. Thank you so much, AThomsen! (GitHub: #68)
*   Do not append template contents if the content hasn't been edited. (GitHub: #62)
*   Add rake task to apply/unapply inherit templates for all the hild projects. (GitHub: #61)

### 0.1.3

NOTE: Please run "rake redmine:plugins:migrate" task because new column is
added.

*   Code refactoring. (Thank you so much for SideCI!)
*   Enabled to use template in case no project parameter passed. (GitHub: #43)
*   Updated the German locale. Thanks, jwciss!
*   Template is loaded after the error when required fields are not filled.
    (GitHub: #50)
*   First implement to integrate Checklist plugin. (GitHub: #39)


### 0.1.2

*   Move repository from Bitbucket to Github.
*   Add Spanish translation. Thanks, Andres Arias (r-labs #1413)
*   Add popup to preview template description and filter template. (Featured:
    r-labs 1410)
*   Bugfix: Prevent to load default template in case updated issue form
    triggered by states change event. (Related: bitbucket#36, Template loads
    every time Status is changed.)
*   Update Simplified Chinese Localization. Thanks,  Steven Wong.
*   Support REST API with json format. (prototype. r-labs #1324)
*   Code refactoring.


### 0.1.1

Bugfix release.

*   Update Brazilian translation file. (Bitbucket Pull Request: #4)
*   Removed deprecation warnings and adjusted gemfile to redmine 3.1.x
    (Bitbucket Pull Request: #5)
*   Bug fix, prevent load template and overwrite description when status
    changed. (Bitbucket Issue: #36)
*   Hide templates Element on Trackers without Issue Template. (Bitbucket
    Issue: #57)
*   Bug fix, when issue create issue from copy, template should not overwrite
    description. (Bitbucket Issue: #70)


Special thanks all contributors, and Mattani-san, to this release.

### 0.1.0

NOTE: Please run "rake redmine:plugins:migrate" task because new column is
added.

*   Support Redmine 3.0. (r-labs: #1366)
*   Add Sort to Global Templates. (r-labs: #1364)
*   Add Polish translation file. (r-labs: #1354)


### 0.0.9

Bug fix release.

*   Fix bug on ruby 1.8. (#52)
*   Remove feature to use JQuery tooltip to preview description, because
    useless. (#50)
*   Change css definition to avoide conflict with Redmine's base style. (#45)
*   Correct migration file to prevent uninstall error. (Related: #54)


### 0.0.8

NOTE: Please run "rake redmine:plugins:migrate" task because new column is
added.

*   Fix some bugs.
*   Support global issue templates.
*   Try to use JQueryUI's tooltip.
*   Add Chinese / zh-TW translation file. Thank you so much, Chinese Spporter!


Known issue:

*   Template loads every time Status is changed
*   https://bitbucket.org/akiko_pusu/redmine_issue_templates/issue/36
*   Only happned in case using default template.


### 0.0.7

NOTE: Please run "rake redmine:plugins:migrate" task because new column is
added.

*   Fix some bugs.
*   Compatible with CKEditor.  (#1280)
*   Add feature to show warning message for orphaned templates. (#1278)
*   Inherited templates only should be listed which tracker is the same to
    child project use. (#1278)
*   Add French translation file. (Bitbucket IssueID:33)
*   Add Serbian translation. Thank you so much, Miodrag Milic. (Bitbucket
    IssueID:34)
*   Add option to change append or replace with template. (#1176)


### 0.0.6

*   Inherited templates from parent project.  (#1267)
*   Add links to template list/edit at project setting tab. (#1269)
*   Add link to erase issue subject and description text.
*   Replace :rubygems in Gemfile with 'https://rubygems.org'. Thanks for
    JohnArcher.
*   Fixed invalid encoding. Thank you so much, Christoph. (#1178)
*   Fixed append "null" string to issue title field. (IssueID: #1268)
*   Prevent to load template when update and redirect with validation error.
    (#1151, #1254)


### 0.0.5

*   Load default template.  (#1088)
*   Show warning message in case no project trackers are assigned.
*   Change CSS style when showing template. (#1141)


### 0.0.4

*   Support Redmine 2.1.x (Now unsupport Redmine 2.0.x. Please use ver 0.0.3
    for Redmine2.0.x) Thak you so much, Viktor Muth, that gave me some
    feedback.

*   Now insert template text just after the text that is already in the
    description field.  (#1115)


### Language and I18n contributors

*   Brazilian: Adriano Ceccarelli / Pedro Moritz de Carvalho Neto
*   Korean: Jaebok Oh
*   Chinese: Steven Wong
*   Bulgarian: Ivan Cenov
*   Russian: Denny Brain, danaivehr
*   German: Terence Miller and anonymous contributor
*   French: Anonymous one
*   Serbian: Miodrag Milic
*   Polish: Paweł Budikom and Krzysztof Wosinski
*   Spanish: Andres Arias
*   Italian: Luca Lesinigo
*   Danish: AThomsen

### Rake Tasks

You can see rake task, with (bundle exec) rake -T, related to this plugin.

Exp.

```
rake redmine_issue_templates:apply_inhelit_template_to_child_projects[project_id]      # Apply inhelit template setting to child projects
rake redmine_issue_templates:default                                                   # Run test for redmine_issue_template plugin
rake redmine_issue_templates:spec                                                      # Run spec for redmine_issue_template plugin
rake redmine_issue_templates:test                                                      # Run tests
rake redmine_issue_templates:unapply_inhelit_template_from_child_projects[project_id]  # Unapply inhelit template setting from child projects
rake redmine_issue_templates:yardoc                                                    # Generate YARD Documentation for redmine_issue_template plugin
```

####

You can apply/unapply inherit templates for all the hild projects.

```
rake redmine_issue_templates:apply_inhelit_template_to_child_projects[project_id]      # Apply inhelit template setting to child projects
rake redmine_issue_templates:unapply_inhelit_template_from_child_projects[project_id]  # Unapply inhelit template setting from child projects
```

If you want to apply inherit templates setting all the child project of project_id: 1 (as parent project), please run rake command like this:

rake redmine_issue_templates:apply_inhelit_template_to_child_projects[1]

### Run test

Please see wercker.yml for more details.

    % cd REDMINE_ROOT_DIR
    % cp plugins/redmine_issue_templates/Gemfile.local plugins/redmine_issue_templates/Gemfile
    % bundle install --with test
    % export RAILS_ENV=test
    % bundle exec rake redmine:plugins:test PLUGIN=redmine_issue_templates

or

    % bundle exec rake redmine_issue_templates:test

#### Run spec

Please see wercker.yml for more details.

    % cd REDMINE_ROOT_DIR
    % cp plugins/redmine_issue_templates/Gemfile.local plugins/redmine_issue_templates/Gemfile
    % bundle install --with test
    % export RAILS_ENV=test
    % bundle exec rspec -I plugins/redmine_issue_templates/spec --format documentation plugins/redmine_issue_templates/spec/

By default, use chrome as a webdriver. If you set environment variable
'DRIVER' to 'headless', headless_chrome is used.

    % bundle exec rspec -I plugins/redmine_issue_templates/spec --format documentation plugins/redmine_issue_templates/spec/ DRIVER='headless'

### License

This software is licensed under the GNU GPL v2.
