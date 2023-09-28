Azul Zulu JDK
=========

This role downloads and installs an Azul Zulu JDK and sets it up as the default JDK on Ubuntu. The .deb files come from [Azul Systems](https://zulu.org).

[![Build Status](https://github.com/Rheinwerk/ansible-role-zulu_jdk/actions/workflows/ci.yml/badge.svg)](https://github.com/Rheinwerk/ansible-role-zulu_jdk/actions/workflows/ci.yml)

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
-----------

None.

Example Playbook
----------------

The general contract of this role is to take the variables map `_zulu_jdk` from `defaults/main.yml` as a template for your configuration and pass that configuration as a parameter to this role.

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: zulu_jdk, tags: [ 'jdk' ] }

License
-------

Please see LICENSE.

Author Information
------------------

Original author is [Daniel Schneller](https://github.com/dschneller) as member of the [Rheinwerk](https://github.com/Rheinwerk) project.

