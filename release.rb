$:.unshift File.dirname(__FILE__)

require 'buildmaster/cotta'
require 'buildmaster/project'

root = BuildMaster::Cotta.file(__FILE__).parent
svn = BuildMaster::SvnDriver.from_path(root)

release = BuildMaster::Release.new
release.task('version') do
  VERSION_NUMBER.increase_build
  SPEC.version = VERSION_NUMBER.version_number
end
release.task("rake") {Rake::Application.new.run}
release.task('commit') {svn.commit('committing before release')}
release.task('tagging') do
  tag = "selenium-#{SPEC.version}"
  puts "tagging with #{tag}"
  svn.tag(tag)
end

release.task("upload") do
  gem = "#{SPEC.name}-#{SPEC.version}"
  target_path = "/var/www/gforge-projects/selenium/builds/#{gem}.gem"
  BuildMaster::PscpDriver.new("#{svn.user}@buildmaster.rubyforge.org").copy(root.file("#{gem}.gem").to_s, target_path)
end

release.command(ARGV)