require_relative 'config.rb'

require 'cinch'
require 'data_mapper'
require_relative 'plugins/tube.rb'
require_relative 'plugins/iplayer.rb'
require_relative 'plugins/hudsonbots.rb'
require_relative 'plugins/admin.rb'
require_relative 'plugins/help.rb'
require_relative 'plugins/shortcuts.rb'
require_relative 'plugins/jira.rb'
require_relative 'plugins/dance.rb'
require_relative 'plugins/featurecrews.rb'
require_relative 'plugins/cat.rb'
require_relative 'plugins/build.rb'
require_relative 'plugins/motd.rb'
require_relative 'plugins/ctcp.rb'
require_relative 'plugins/dontsay.rb'
require_relative 'plugins/md5.rb'
require_relative 'plugins/codereview.rb'
require_relative 'plugins/fishslap.rb'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:///' + DBFILE)

# If database doesn't exist, create. Else update
if File.exists?(DBFILE)
	DataMapper.auto_upgrade!
else
	DataMapper.auto_migrate!
end

bot = Cinch::Bot.new do
	configure do |c|
		c.server = IRC_SERVER
		c.port = IRC_PORT
		c.nick = 'redpanda'
		c.name = 'redpanda'
		c.user = 'redpanda'
		c.realname = 'iPlayer Bot - Jak Spalding - try !help'
		c.channels = ['#iplayer', '#playback', '#ibl', '#penguins']
		c.plugins.plugins = [
			TubeStatus, 
			Iplayer, 
			HudsonBots, 
		  Admin, 
			Help, 
			Shortcuts,
			Jira,
			Dance,
			FeatureCrews,
			Cat,
			Build,
			Motd,
			Ctcp,
			Dontsay,
			Md5,
      Codereview,
      Fishslap
		]
		c.ssl.use = true
		c.ssl.verify = false
		c.ssl.client_cert = CERTIFICATE_PATH
	end
end

bot.start
