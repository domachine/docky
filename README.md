# docky

Simple deployment tool for hosts without `systemd` like we have :(.

## First draft

Simple rebuild script for already running containers. Think of the following.

You've got a project called `foobar` which is written in *nodejs*. It requires a
*redis* store and a *mongodb*. You want to deploy your project within a docker
container. You would do this like this:

    $ cd foobar/
    $ docker run -d --name foobar-mongo mongo
    $ docker run -d --name foobar-redis redis
    $ docker build -t foobar:0.0.0 .
    $ docker run -d -p 127.0.0.1::3000 --link foobar-mongo:mongo --link foobar-redis:redis foobar:0.0.0

Now there comes the time when you ship an update of your application. So you
update the version in your `package.json` to `0.0.1`. Now `docky` can help you
to do this. For this purpose you throw a file called `docker_run.sh` in your
project. The content is the following:

```sh
docker run -d -p 127.0.0.1:$port:3000 \
  --link $name-mongo:mongo \
  --link $name-redis:redis $name:$version
```

Now call `/path/to/bin/docky.sh rebuild` from within your project root. `docky` will then rebuild
your image using the new version as a tag, tear down the old container and call
your `docker_run.sh` script to rebuild the container preserving the previously
assigned port.

## See also

To get much fancier and also integrate `systemd` within your stack take a look
at [Geard](https://openshift.github.io/geard/) from the guys at OpenShift.
`docky` just wants to deploy a fixed container set and can be easily replaced by
`Geard`.
