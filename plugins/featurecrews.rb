require 'cinch'
require 'data_mapper'

class Team
	include DataMapper::Resource

	has n, :members

	property :name, String, unique: true, key: true
end

class Member
	include DataMapper::Resource

	belongs_to :team

	property :id, Serial
	property :nick, String
end

class FeatureCrews
	include Cinch::Plugin

	match /team add ([A-Za-z]+) ([A-Za-z0-9\-]+)/, method: :add_member
	match /team remove ([A-Za-z]+) ([A-Za-z0-9\-]+)/, method: :remove_member
	match /team create ([A-Za-z]+)/, method: :create_team
	match /team delete ([A-Za-z]+)/, method: :delete_team
	match /team members ([A-Za-z]+)/, method: :list_members
	match /team list$/, method: :list_teams
	match /team help/, method: :help
	match /team$/, method: :help
	match /^([A-Za-z]+)[,:]/, method: :list_team, use_prefix: false

	def help(m)
		m.reply "Usage: !team (add|remove) <team> <nickname>"
		m.reply "Usage: !team (members|create|delete) <team>"
		m.reply "Usage: !team (list|help)"
	end

	def create_team(m, team_name)
		begin
			team = Team.create(:name => team_name.downcase.strip)
			m.reply "Created a new team!"
			m.reply "Add yourself using !team add #{team_name} #{m.user.nick}"
		rescue => error
			m.reply "Uh-oh spaghetti-o's"
		end
	end

	def delete_team(m, team_name)
		begin
			team = Team.get(team_name)
			team.destroy
			m.reply "Team deleted :-("
		rescue
			m.reply "Uh-oh spaghetti-o's"
		end
	end

	def add_member(m, team_name, member_name)
		begin
			team = Team.get(team_name)
			member = Member.create(:nick => member_name, :team => team)
			m.reply "Added #{member_name} to #{team_name}"
		rescue
			m.reply "Uh-oh spaghetti-o's"
		end
	end

	def remove_member(m, team_name, member_name)
		begin
			member = Team.get(team_name).members.first(:nick => member_name)
			if member.nil?
				m.reply "Couldn't find #{member_name} in Team #{team_name.capitalize}"
				return
			end
			member.destroy
			m.reply "#{member_name} has been removed from Team #{team_name.capitalize}"
		rescue
			m.reply "Uh-oh spaghetti-o's"
		end
	end

	def list_members(m, team_name)
		begin
			team = Team.get(team_name)
			nicks = []
			team.members.each do |member|
				nicks << member.nick
			end
			m.reply nicks.join(', ')
		rescue
			m.reply "Uh-oh spaghetti-o's"
		end
	end

	def list_teams(m)
		begin
			teams = Team.all
			names = []
			teams.each do |team|
				names << "Team #{team.name.capitalize}"
			end
			m.reply names.join(', ')
		rescue
			m.reply "Uh-oh spaghetti-o's"
		end
	end

end
