#!/usr/bin/env ruby

##
# Asana API library and command-line client
# Tommy MacWilliam <tmacwilliam@cs.harvard.edu>
#
#

require "rubygems"
require "JSON"
require "net/https"
require "yaml"
require "chronic"

module Asana
    # initialize config values
    def Asana.init
        begin
            @@config = YAML.load_file File.expand_path "~/.asana-client"
        rescue
            abort "Configuration file could not be found.\nSee https://github.com/tmac721/asana-client for installation instructions."
        end
    end

    # parse argumens
    def Asana.parse(args)
        # no arguments given
        if args.empty?
            abort "Nothing to do here."
        end

        # concatenate array into a string
        string = args.join " "

        # finish n: complete the task with id n
        if string =~ /^finish (\d+)$/
            Asana::Task.finish $1
            puts "Task completed!"
            exit
        end

        # workspace: display tasks in that workspace
        if string =~ /^(\w+)$/
            # get corresponding workspace object
            workspace = Asana::Workspace.find $1
            abort "Workspace not found!" unless workspace

            # display all tasks in workspace
            puts workspace.tasks unless workspace.tasks.empty?
            exit
        end

        # workspace/project: display tasks in that project
        if string =~ /^(\w+)\/(\w+)$/
            # get corresponding workspace
            workspace = Asana::Workspace.find $1
            abort "Workspace not found!" unless workspace

            # get corresponding project
            project = Asana::Project.find workspace, $2
            abort "Project not found!" unless project

            # display all tasks in project
            puts project.tasks unless project.tasks.empty?
            exit
        end

        # extract assignee, if any
        assignee = nil
        args.each do |word|
            if word =~ /^@(\w+)$/
                assignee = word[1..-1]
                args.delete word
            end
        end

        # extract due date, if any
        due = Chronic.parse(args.reverse[0..1].reverse.join(" "))
        if !due.nil? && due.to_s =~ /(\d+)-(\d+)-(\d+)/
            # penultimate word is part of the date or a stop word, so remove it
            if Chronic.parse(args.reverse[1]) || ["due", "on", "for"].include?(args.reverse[1].downcase)
                args.pop
            end

            # extract date from datetime and remove date from task name
            args.pop
            due = "#{$1}-#{$2}-#{$3}"
        end

        # reset string, because we modifed argv
        string = args.join " "

        # workspace task name: create task in that workspace
        if string =~ /^(\w+) ([\w ]+)/
            # get corresponding workspace 
            workspace = Asana::Workspace.find $1

            # create task in workspace
            Asana::Task.create workspace, $2, assignee, due
            puts "Task created in #{workspace.name}!"
            exit
        end

        # workspace/project task name: create task in that workspace
        if string =~ /^(\w+)\/(\w+) ([\w ]+)/
            # get corresponding workspace 
            workspace = Asana::Workspace.find $1

            # create task in workspace
            Asana::Task.create workspace, $3, assignee, due

            # get corresponding project
            project = Asana::Project.find workspace, $2
            abort "Project not found!" unless project

            # add task to project
            Asana.post "tasks/#{task['data']['id']}/addProject", { "project" => project.id }
            puts "Task created in #{workspace.name}/#{project.name}!"
            exit
        end
    end

    # perform a GET request and return the response body as an object
    def Asana.get(url)
        # set up http object
        uri = URI.parse "https://app.asana.com/api/1.0/" + url
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        # all requests are json
        header = {
            "Content-Type" => "application/json"
        }

        # make request
        req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}", header)
        req.basic_auth @@config["api_key"], ''
        res = http.start { |http| http.request req }

        # return request object
        return JSON.parse(res.body)
    end

    # perform a PUT request and return the response body as an object
    def Asana.put(url, data, query = nil)
        # set up http object
        uri = URI.parse "https://app.asana.com/api/1.0/" + url
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        # all requests are json
        header = {
            "Content-Type" => "application/json"
        }

        # make request
        req = Net::HTTP::Put.new("#{uri.path}?#{uri.query}", header)
        req.basic_auth @@config["api_key"], ''
        req.set_form_data data 
        res = http.start { |http| http.request req  }

        # return request object
        return JSON.parse(res.body)
    end

    # perform a POST request and return the response body as an object
    def Asana.post(url, data, query = nil)
        # set up http object
        uri = URI.parse "https://app.asana.com/api/1.0/" + url
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        # all requests are json
        header = {
            "Content-Type" => "application/json"
        }

        # make request
        req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", header)
        req.basic_auth @@config["api_key"], ''
        req.set_form_data data 
        res = http.start { |http| http.request req  }

        # return request object
        return JSON.parse(res.body)
    end

    # get all of the users workspaces
    def Asana.workspaces
        spaces = self.get "workspaces" 
        list = []

        # convert array to hash indexed on workspace name
        spaces["data"].each do |space|
            list.push Workspace.new :id => space["id"], :name => space["name"]
        end

        list
    end

    class Project
        attr_accessor :id, :name, :workspace

        def initialize(hash)
            self.id = hash[:id] || 0
            self.name = hash[:name] || ""
            self.workspace = hash[:workspace] || nil
        end

        # search for a project within a workspace
        def self.find(workspace, name)
            # if given string for workspace, convert to object
            if workspace.is_a? String
                workspace = Asana::Workspace.find workspace 
            end

            # check if any workspace contains the given name, and return first hit
            name.downcase!
            if workspace
                workspace.projects.each do |project|
                    if project.name.downcase.include? name
                        return project
                    end
                end
            end

            nil
        end

        # get all tasks associated with the current project
        def tasks
            task_objects = Asana.get "tasks?workspace=#{workspace.id}&project=#{self.id}"
            list = []

            task_objects["data"].each do |task|
                list.push Task.new :id => task["id"], :name => task["name"],
                    :workspace => self.workspace, :project => self
            end

            list
        end
    end

    class Task
        attr_accessor :id, :name, :workspace, :project

        def initialize(hash)
            self.id = hash[:id] || 0
            self.name = hash[:name] || ""
            self.workspace = hash[:workspace] || nil
            self.project = hash[:project] || nil
        end

        # create a new task on the server
        def self.create(workspace, name, assignee = nil, due = nil)
            # if given string for workspace, convert to object
            if workspace.is_a? String
                workspace = Asana::Workspace.find workspace 
            end
            abort "Workspace not found" unless workspace

            # if assignee was given, get user
            if !assignee.nil?
                assignee = Asana::User.find workspace, assignee 
                abort "Assignee not found" unless assignee
            end

            # add task to workspace
            params = {
                "workspace" => workspace.id, 
                "name" => name,
                "assignee" => (assignee.nil?) ? "me" : assignee.id
            }
    
            # attach due date if given
            if !due.nil?
                params["due_on"] = due
            end

            # add task to workspace
            Asana.post "tasks", params
        end

        # finish a task
        def self.finish(id)
            Asana.put "tasks/#{id}", { "completed" => true }
        end

        def to_s
            "(#{self.id}) #{self.name}"
        end
    end

    class User
        attr_accessor :id, :name

        def initialize(hash)
            self.id = hash[:id] || 0
            self.name = hash[:name] || ""
        end

        def self.find(workspace, name)
            # if given string for workspace, convert to object
            if workspace.is_a? String
                workspace = Asana::Workspace.find workspace 
            end

            # check if any workspace contains the given name, and return first hit
            name.downcase!
            workspace.users.each do |user|
                if user.name.downcase.include? name
                    return user
                end
            end

            nil
        end

        def to_s
            self.name
        end
    end

    class Workspace
        attr_accessor :id, :name

        def initialize(hash)
            self.id = hash[:id] || 0
            self.name = hash[:name] || ""
        end

        # search a workspace by name
        def self.find(name)
            # check if any workspace contains the given name, and return first hit
            name.downcase!
            Asana.workspaces.each do |workspace|
                if workspace.name.downcase.include? name
                    return workspace
                end
            end

            nil
        end

        # get all projects associated with a workspace
        def projects
            project_objects = Asana.get "projects?workspace=#{self.id}"
            list = []

            project_objects["data"].each do |project|
                list.push Project.new :id => project["id"], :name => project["name"], :workspace => self
            end

            list
        end

        # get tasks assigned to me within this workspace
        def tasks
            task_objects = Asana.get "tasks?workspace=#{self.id}&assignee=me"
            list = []

            task_objects["data"].each do |task|
                list.push Task.new :id => task["id"], :name => task["name"],
                    :workspace => self
            end

            list
        end

        # get all users in the workspace
        def users
            user_objects = Asana.get "workspaces/#{self.id}/users"
            list = []

            user_objects["data"].each do |user|
                list.push User.new :id => user["id"], :name => user["name"]
            end

            list
        end
    end
end


if __FILE__ == $0
    Asana.init
    Asana.parse ARGV
end
