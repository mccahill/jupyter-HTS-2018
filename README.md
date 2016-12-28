Source for Jupyter notebooks for the STA663 course, and the other containers
we also run to support this (nginx, docker-gen, mysql).

If you are only interested in the STA663 course notebook itself, see the
directory

```
     ./src/STA663-notebook
```

The other modules are also in the src file, but should not need to be edited
since we are using the standard Nginx proxy, Docker-gen, and MySQL Docker containers
that are used for all the other courses (i.e. Coursera, Intro Statistics, and the generic
Jupyter container).
