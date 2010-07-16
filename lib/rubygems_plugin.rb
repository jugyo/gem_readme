require 'rubygems/command_manager'

require 'gem_readme/readme_command'
Gem::CommandManager.instance.register_command :readme
