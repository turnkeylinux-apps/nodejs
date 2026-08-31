Node.js - Asynchronous JavaScript Framework
===========================================

`Node.js`_ is a cross-platform JavaScript runtime environment built on Chrome's
V8 JavaScript engine. Node.js uses an event-driven, non-blocking I/O model
that makes it lightweight and efficient, especially for server-side
and networking applications. `npm`_ is its package manager and application
dependency update path.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

-  Node.js configurations:

   - Node.js 20 and npm installed from Debian Trixie and maintained through
     APT::

        apt update
        apt install --only-upgrade nodejs npm

   - Support for `installing npm packages globally`_ more securely
     without root or sudo::

        su node
        npm install -g package

   - npm now supports security `audit`_ (replaces nsp). Provides subcommand
     fix, to automatically install compatible updates to vulnerable
     dependencies. E.g.::

        su node
        cd /opt/your-awesome-node-app
        npm audit
        npm audit fix

   - A systemd `PM2`_ service at ``/etc/systemd/system/pm2-node.service`` runs
     Node.js applications on boot. PM2 is installed from npm and can be
     updated through npm::

        npm install --global pm2@latest
     
     pm2 is a production process manager that helps keep your node apps
     running, supports clustering and makes it easy to manage node
     apps::

        # su node
        $ pm2 start --max-memory-restart 500M /opt/yourapp/app.js
        $ pm2 stop tklweb-cp
        $ pm2 list

   - Default Nginx configuration template::

        server {
            listen 0.0.0.0:80 default_server;

            set $nodeapp_port 8000;
            include /etc/nginx/include/nodejs-proxy;
        }

   - npm bash tab-completion::

        $ npm in<tab>
        info     init     install

   - Node.js example applications, retained as Git checkouts so they can be
     refreshed from their upstream repositories::

        $ ls /opt/node-examples
        express_example  node-by-example  nodejsbook.io.examples  practicalnode

        $ git -C /opt/node-examples/express_example pull --ff-only

   - Default web page / control panel at /opt/tklweb-cp is itself an example
     Node.js app built with express and `pug`_ templating. 
   
   - `PM2`_: production process manager. Configured to start on boot as a
    systemd service.

  
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).

- Webmin modules for configuring Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**

.. _npm: https://www.npmjs.com/
.. _PM2: https://github.com/Unitech/pm2
.. _pug: https://pugjs.org/

.. _installing npm packages globally: https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
.. _Node.js: https://nodejs.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
