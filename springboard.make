; Springboard Distribution dev snapshot makefile
; The purpose of this makefile is to make it easier for people to install
; the dev version of Springboard and its dependencies, including patches, before
; a new full release of the distribution is rolled.  

api = 2
core = 6.x

;Contrib modules
projects[views][subdir] = contrib
projects[cck][subdir] = contrib
projects[pathauto][subdir] = contrib
projects[ctools][subdir] = contrib
projects[token][version] = "1.15" 
projects[token][subdir] = contrib
projects[webform][version] = "3.14"
projects[webform][subdir] = contrib
projects[securepages][version] = "1.9"
projects[securepages][subdir] = contrib
projects[skinr][subdir] = contrib
projects[admin_menu][subdir] = contrib
projects[email][subdir] = contrib
projects[features][subdir] = contrib
projects[webform_ab][subdir] = contrib
projects[encrypt][subdir] = contrib

;Development modules
projects[coder][subdir] = "developer"
projects[coder][version] = "2.0-beta1"
projects[devel][subdir] = "developer"
projects[devel][version] = "1.23"
projects[schema][subdir] = "developer"
projects[schema][version] = "1.7"
projects[simpletest][subdir] = "developer"
projects[simpletest][version] = "2.11"

;Themes
projects[fusion][type] = theme
projects[fusion][download][type] = git
projects[fusion][download][url] = "http://git.drupal.org/project/fusion.git"

;Springboard
projects[springboard_modules][type] = module
projects[springboard_modules][download][type] = git
projects[springboard_modules][download][url] = "git://github.com/JacksonRiver/springboard_modules.git"
projects[springboard_modules][download][branch] = 6.x-3.0-dev


