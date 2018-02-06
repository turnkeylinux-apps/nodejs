Node.js - Asynchronous Javascript Framework
===========================================

`Node.js`_ is a cross-platform Javascript runtime environment built on Chrome's
V8 JavaScript engine. Node.js uses an event-driven, non-blocking I/O model
that makes it lightweight and efficient, especially for server-side
and networking applications. `npm`_, Nodes package ecosystem is the largest ecosystem
of open source libraries in the world.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

-  Node.js configurations:

   - `n`_ Node Version Manager used to install the latest stable version of
     Node. `n`_ supports updating Node to the latest version and switching between
     multiple older versions::

        # install latest stable node
        n stable

        # show all installable versions
        n list

        # install specific version
        n <version>

   - Support for `installing npm packages globally`_ more securely
     without root or sudo::

        su node
        npm install -g package

   - systemd `PM2`_ service at /etc/systemd/system/pm2-node.service runs
     node apps on boot. 
     
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

   - hundreds of node example apps::

        $ ls /opt/node-examples
        express_example  node-by-example  nodejsbook.io.examples  practicalnode

   - Default web page / control panel at /opt/tklweb-cp is itself an example
     Node.js app built with express and jade templating. 

- Bundled globally-installed Node.js packages:

  - `PM2`_: production process manager. Configured to start on boot as a
    systemd service.

  - `forever`_: a simple CLI tool for ensuring a node app runs continuously.
    Supports watching sources for changes and restarting app.

  - `grunt`_: task runner that automates repetitive tasks like minifcation,
    compilation, unit testing and linting.
  - `bower`_: package manager for client-side browser dependencies
  - `nsp`_: Node Security Project package auditor. Audits dependencies
    for known security vulnerabilities::

        cd /opt/yournodeapp
        nsp audit-package

- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).

- Webmin modules for configuring Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**

.. _npm: https://www.npmjs.com/

.. _n: https://github.com/tj/n
.. _PM2: https://github.com/Unitech/pm2
.. _forever: https://github.com/foreverjs/forever
.. _grunt: http://gruntjs.com/
.. _bower: http://bower.io/
.. _nsp: https://github.com/nodesecurity/nsp

.. _Chrome devtools: https://developer.chrome.com/devtools
.. _installing npm packages globally: https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
.. _Node.js: https://nodejs.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
