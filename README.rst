node.js - Asynchronous Javascript Framework
===========================================

`node.js`_ is a platform built on Chrome's JavaScript runtime for easily
building fast, scalable network applications. Node.js uses an
event-driven, non-blocking I/O model that makes it lightweight and
efficient, perfect for data-intensive real-time applications that run
across distributed devices.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- node.js configurations:
   
   - Installed from upstream source code in /usr/local/src/node.
   - Includes NPM, with npm-completion out of the box.
   - Includes custom nodejs initscript for running node app as daemon.
   - Includes nginx pre-configured to proxy to nodejs daemon
   - Includes TurnKey Web Control panel with links to useful references,
     built on expressjs with jade templating (/opt/tklweb-cp).

- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**


.. _node.js: http://nodejs.org/
.. _TurnKey Core: http://www.turnkeylinux.org/core
