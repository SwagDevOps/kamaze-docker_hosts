# Keep hosts up-to-date with ``docker-api``

``kamaze-docker_hosts`` is based on top of [``docker-api``][docker-api].
It provides a CLI, through ``docker-hosts`` executable,
to manipulate the operating system's host files. ``watch`` command will keep
``hosts`` file updated according to ``docker`` network changes.

In the future, ``cli`` will be separated from the ``core`` library.

## Configuration

``cli`` uses the ``core`` config files, unless ``/etc/docker-hosts``
config directory is present with expected files.
Config directory can also be given from the ``cli`` option
``-c`` or ``--config``.

Config can be displayed (after __overlaying__)
with the ``config`` command, rendered with JSON notation.

[docker-api]: https://github.com/swipely/docker-api
