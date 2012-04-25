Asana Command-Line Client
===

Command-line client for viewing, adding, and completing tasks in Asana. Whenever you mention a workspace, project, or user, you don't need to use the entire word. For example, you can use "projects" to refer to a workspace called "Personal Projects" or "@tommy" to refer to a user named "Tommy MacWilliam". As long as what you supply is contained within the full workspace/project/user name on Asana, the client will figure out what you mean.

### Installation

    $ gem install chronic

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
