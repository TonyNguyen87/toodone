require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/list"
require "too_done/task"

require "thor"
require "pry"

module TooDone
  class App < Thor
      # find or create the right todo list
      # create a new item under that list, with optional date
    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task) 

      list = List.find_or_create_by(user_id: current_user.id, title: options[:list])
      task = Task.find_or_create_by(item: task, list_id: list.id, due_date: options[:date])
      puts "Your task, #{task.item}, was added to list: #{list.title}"
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      list = List.find_by(title: options[:list])
      unless list
        puts "No such list: #{options[:list]} for #{current_user.name}"
        exit
      end
      tasks = Task.where(list_id: list.id).each { |task| 
                  puts "#{task.id}. #{task.item}"}
      unless tasks.count > 0
          puts "No tasks on this list"
          exit
      end
      puts "Please input a number for which task you would like to edit.."
      choice = STDIN.gets.chomp.to_i
      puts "What will the new title be?"
      new_title = STDIN.gets.chomp
      puts "What will the new due_date be(YYYY-MM-DD)?"
      new_date = STDIN.gets.chomp
      task = Task.find(choice)
      updated = task.update_attributes(item: new_title, due_date: new_date)
      #do i need to do updated.save here?
      puts "You've successfully updated the task!"
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      # allow the user to change the title, due date
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      list = current_user.lists.find_by(title: options[:list])
      unless list && list.tasks.count > 0
        puts "No such list or its empty"
        exit
      end
      Task.where(list_id: list.id).each {|x| puts "#{x.id}: #{x.item}"}
      puts "Please choose a task number to mark done"
      choice = STDIN.gets.chomp.to_i
      task = Task.find(choice)
      complete = task.update_attributes(completed: true)
      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      list = List.find_or_create_by(title: options[:list])
      tasks = Task.where(list_id: list.id)
      binding.pry
      if options[:sort] == "history"
       Task.where(list_id: list.id).each {|x| puts "#{x.id}: #{x.item} Due-date: #{x.due_date}"}
      elsif options[:sort] == "overdue"
        Task.where(list_id: list.id).each {|x| puts "#{x.id}: #{x.item} Due-date: #{x.due_date}"}
      else 
        Task.where(list_id: list.id).each {|x| puts "#{x.id}: #{x.item} Due-date: #{x.due_date}"}.reverse
      end   
      # find or create the right todo list
      # show the tasks ordered as requested, default to reverse order (recently entered first)
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      unless option[:list] && option[:user]
        if user = User.find_by(name: options[:user])
            user.destroy.all
        else list = List.where(title: options[:list])
            list.destory.all
        end
      exit
      end
      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)
    end

    desc "switch USER", "Switch session to manage USER's todo lists."
    def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user
      Session.last.user
    end
  end
end
# binding.pry
TooDone::App.start(ARGV)
