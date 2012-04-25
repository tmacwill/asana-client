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

### View all of the tasks in a project

    $ asana workspace/project

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

Copy the <tt>post-commit</tt> file into your repo's <tt>.git/hooks</tt> directory, and make sure to execute <tt>chmod +x .git/hooks/post-commit</tt> from the root of your repo. Now, simply mention the ID of an Asana task inside your commit message, and the issue will be closed automatically and a comment with the relevent commit will be posted. For example, if you determine a relevant bug has an ID of 12345 (using the asana command-line client), you could say <tt>git commit -m "this commit fixes issue 12345"</tt>.
