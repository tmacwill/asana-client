Asana Command-Line Client
===

Command-line client for viewing, adding, and completing tasks in Asana. Whenever you mention a workspace, project, or user, you don't need to use the entire word. For example, you can use "projects" to refer to a workspace called "Personal Projects" or "@tommy" to refer to a user named "Tommy MacWilliam". As long as what you supply is contained within the full workspace/project/user name on Asana, the client will figure out what you mean.

## Installation

    $ gem install asana-client

Now, open up Asana's web app and select "Account Settings". You should see a tab that says "API". Copy the text, then execute the following:

    $ echo "api_key: PASTE_YOUR_API_KEY_HERE" > ~/.asana-client

Basically, that's just creating a YAML configuration file (containing your API key) called <tt>.asana-client</tt> in your home directory.

## Command-Line Client

### View all of the tasks assigned to you in a workspace

    $ asana workspace

To also list completed tasks, add the `-c` flag.

### View all of the tasks in a project

    $ asana workspace/project

As for workspaces, add the `-c` flag to also list completed tasks.
The `-m` flag can be given to only list tasks assigned to you.

### Create a new task in a workspace

    $ asana workspace this is the name of my new task

### Create a new task in a project

    $ asana workspace/project this is the name of my new task

### Assign a task when creating it

    $ asana workspace/project do that the important thing @tommy

### Set a deadline when creating a task

    $ asana workspace/project fix it @tommy 4/25/12
    $ asana workspace/project paper due friday

### Complete a task

    $ asana finish 12345

## Git Integration

Copy the <tt>post-commit</tt> file into your repo's <tt>.git/hooks</tt> directory, and make sure to execute <tt>chmod +x .git/hooks/post-commit</tt> from the root of your repo.

Now, simply mention the ID of an Asana task inside your commit message, and the issue will be annotated automatically with your commit message and will optionally complete the task. If you're familiar with git annotations with Pivotal Tracker, these will be second nature. Commit message examples:

action | commit
------- | --------
annotate a task without finishing it | git commit -m "convert tabs to spaces in sort.c [#1234567890]"
annotate a task and finish it | git commit -m "fix tricky bug [fixes #1234567890]"
annotate a task and finish it | git commit -m "finish converting tabs [finishes #1234567890]"