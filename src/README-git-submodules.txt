-----------------
git submodule fun
-----------------
This project has multiple components that are in independent git repositories.
   nginx
   docker-gen
   mysql
   ipython-sql
   
To deal with this (and have everything in one place so it is possible to simplyfy
building it all) I am using git 'submodules' which have some quirks. To get
a complete clone of everything, do a git clone (or pull) of the project, then
inside the project directory do this:

   git submodule init
   git submodule update
   
or, after the initial setup with git init, so this:

   git submodule foreach git pull origin master

this pulls the submodule code. If you want to check on the submodule status after 
they have been init'ed do this:

   git submodule foreach git status
   
In fact, you can run arbotrary scripts in each of the submodules in a similar way.

