Source for the HTS-2017 course's Jupyter notebook docker 
containers is found in

```
    ./src/HTS-2017-notebook
```

Note that in addition to the Jupyter notebook container we
also have submodules for mysql, nginx, and docker-gen to
provide a MySQL server, an Nginx https proxy, and auto-configation
of the Nginx proxy (via docker-gen). These are here mainly to 
keep all the components for the course in one place and simplify
provisioning the whole service onto arbitraty VMs.

So you probably don't need to look at or worry about anything except

```
    ./src/HTS-2017-notebook
```

