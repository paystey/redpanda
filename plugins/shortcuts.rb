require 'cinch'
require 'data_mapper'

class Shortcut
	include DataMapper::Resource

	property :id, Serial
	property :command, String, unique: true
	property :contents, String
	property :created_by, String
end

class Shortcuts
	include Cinch::Plugin

	match /set ([A-Za-z0-9]+) (.+)/, method: :add_shortcut
	match /\?([A-Za-z0-9]+)/, method: :get_shortcut, use_prefix: false
	match /shortcuts/, method: :list_shortcuts

	def add_shortcut(m, command, contents)
		begin
			shortcut = Shortcut.first_or_new(
				{ :command.like => command.downcase.strip },
				{ :command => command.downcase.strip }
			)
			shortcut.contents = contents
			shortcut.created_by = m.user.nick
			shortcut.save
			m.safe_reply "Saved, use ?#{command} to retrieve"
		rescue => error
			m.reply "Uh-oh spaghetti-o's!"
		end
	end

	def get_shortcut(m, command)
		begin
			shortcut = Shortcut.first(:command.like => command.downcase.strip)
			if shortcut.nil?
				m.safe_reply "Nothing found. Add something using '!set #{command.strip} useful stuff here'"
			else
				m.safe_reply "?? " << shortcut.contents
			end
		rescue => error
			m.reply "Uh-oh spaghetti-o's!"
		end
	end

	def list_shortcuts(m)
		begin
			shortcuts = Shortcut.all(fields: [:command])
			commands = []
			shortcuts.each do |s|
				commands << "?#{s.command}"
			end
			m.safe_reply "Available shortcuts: " << commands.join(', ')
			m.reply "Add a new shortcut using !set <shortcut> <some text here>"
		rescue
			m.reply "Uh-oh spaghetti-o's!"
		end
	end
end
