= Updater

An updater for Simple Web-Based, Git-Based Projects

Author: Stoney Jackson (dr.stoney@gmail.com)
License: LGPL V3 (http://www.gnu.org/licenses/lgpl.html)

== Might be for you if ...

* You use git.
* You have a simple web-based project.
* You're deploying to an Apache web-server.
* You use tags to mark releases.
* You store the version number, and only the version number, in /VERSION  of
  your project, and it only contains the version number on the first line.
* You want a more automated way to update deployements to the most resent
  release.

== Requires

* bash (developed with GNU bash, version 4.2)
* PHP if web access is desired (developed with 5.4)
* git (developed with version 1.8)
* ssh (developed with OpenSSH 6.2)

== Install

Copy src/ to your project and give it an appropriate name (updater here).

    $ cp -R src/ /path/to/project/updater

Set the correct version in your project (if necessary).

    $ cd /path/to/project
    $ echo "1.0" > VERSION

Set the url to the repository.

    $ cd updater/private
    $ cp REPOSITORY.example REPOSITORY
    $ vim REPOSITORY

Set the repository branch that contains releases.

    $ cp BRANCH.example BRANCH
    $ vim BRANCH

Set the password for web access control.

    $ cp PASSWORD.example PASSWORD
    $ vim PASSWORD

Generate deployment key. Do not provide a passphrase. Install deployment-key.pub
in .ssh/authorized-keys on the server hosting the git repository.

    $ ssh-keygen -t rsa -C "deployment-key" -f deployment-key

== Using Updater via Web

Point browser to deployed/updater

== Apply Patch Created by `git format-patch` via Web

Point browser to deployed/updater/patch.php

