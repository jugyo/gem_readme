require 'rubygems/command'
require 'rubygems/version_option'

class Gem::Commands::ReadmeCommand < Gem::Command

  OPTIONS = {
    :version => Gem::Requirement.default,
    :editor => 'less'
  }

  include Gem::VersionOption

  def initialize
    super 'readme', 'Open a README of an installed gem', OPTIONS

    add_version_option

    add_option('-e', '--editor EDITOR', String,
               'The editor to use to open the gems',
               "Default: #{OPTIONS[:editor]}") do |editor, options|
      options[:editor] = editor
    end
  end

  def arguments # :nodoc:
    "GEMNAME       name of gem to open README"
  end

  def defaults_str # :nodoc:
    "--version '#{OPTIONS[:version]}' --editor #{OPTIONS[:editor]}"
  end

  def usage # :nodoc:
    "#{program_name} [options] GEMNAME [GEMNAME ...]"
  end

  def execute
    version = options[:version] || OPTIONS[:version]

    gem_specs = get_all_gem_names.map { |gem_name| Gem.source_index.find_name(gem_name, version).last }.compact

    if gem_specs.size > 0
      paths = gem_specs.map { |spec| spec.full_gem_path }

      readmes = paths.inject([]) do |result, path|
        result + Dir[File.join(path, '*')].select{ |i| File.basename(i) =~ /^readme/i }
      end

      if readmes.empty?
        say "README not found!"
        exit!
      end

      cmd = "#{options[:editor]} #{readmes.join(' ')}"
      exec cmd unless options[:dryrun]
    else
      say "No gems found for #{get_all_gem_names.join(', ')}"
      raise Gem::SystemExitException, 1
    end
  end
end
