require 'extend/pathname'

module Homebrew
  def which_versions which_brews=nil
    opoo <<-EOS.undent
      brew which is unsupported and will be removed soon.

      You should use `brew list --versions` instead.
      To query other formula information see:
        https://github.com/Homebrew/homebrew/wiki/Querying-Brew

      Please feel free volunteer to support it in a tap.

    EOS

    brew_links = Array.new
    version_map = Hash.new

    real_cellar = HOMEBREW_CELLAR.realpath

    (HOMEBREW_PREFIX/'opt').subdirs.each do |path|
      next unless path.symlink? && path.resolved_path_exists?
      brew_links << Pathname.new(path.realpath)
    end

    brew_links = brew_links.collect{|p|p.relative_path_from(real_cellar).to_s}.reject{|p|p.start_with?("../")}

    brew_links.each do |p|
      parts = p.split("/")
      next if parts.count < 2 # Shouldn't happen for normally installed brews
      brew = parts.shift
      version = parts.shift

      next unless which_brews.include? brew if which_brews

      versions = version_map[brew] || []
      versions << version unless versions.include? version
      version_map[brew] = versions
    end

    return version_map
  end

  def which
    which_brews = ARGV.named.empty? ? nil : ARGV.named

    brews = which_versions which_brews
    brews.keys.sort.each do |b|
      puts "#{b}: #{brews[b].sort*' '}"
    end
    puts
  end
end

Homebrew.which
