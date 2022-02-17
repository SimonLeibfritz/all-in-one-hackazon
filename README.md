# Reason for this fork
The original work created by [cmutzel](https://github.com/cmutzel) creates a new password on every start of the container (by executing the `start.sh` file). \
I could not verify if this is intentional or just a side product. The only thing I know is, that restarting the original container will result in a different password being displayed, whilst the old password is still the only valid one.

Since I don't need changing passwords anyways (at least for my current use case), I added a check for existing passwords, and did some smaller fixes whilst at it.

# About
Run a docker container include hackazon, apache, mysql, and nodejs with express server

This work is based on https://github.com/cmutzel/all-in-one-hackazon

# Instructions
1. You cant either...

   ...clone my repository from dockerhub
   ```
   docker pull dieschdel/all-in-one-hackazon
   ```
   
   ...or build the image yourself (after cloning this repo):
   ```
   docker build --rm --tag all-in-one-hackazon .
   ```

2. then run via: 
```
docker run --name hackazon -d -p 80:80 --name hackazon all-in-one-hackazon
```

3. you can now access your hackazon instance via `http://<host e.g. 'localhost'>`


# Login and credentials
you can access your docker logs with following command
```
docker logs hackazon
```

inside your logs you'll find your login credentials 

```sh
---------- LOGIN INFORMATION ----------
mysql: root@<mysql password>
hackazon: admin@<hackazon password>
---------------------------------------
```

**NOTE**: passwords will be create once (semi-randomly) on startup. These are obviously not secure and should not be used outside hackazon. \
If you prefer a static password instead, you'll have to replace following two lines (located in `.scripts/start.sh`) with your own password.
```sh
MYSQL_PASSWORD=`date +%N|sha256sum|base64|head -c 10`
...
HACKAZON_PASSWORD=`date +%N|sha256sum|base64|head -c 10`

vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

MYSQL_PASSWORD="my_really_secure_password"
...
HACKAZON_PASSWORD="my_really_secure_password"
```
Rebuild your container afterwards.
