# Third-Party Notices

Brun uses third-party open-source software. This file lists each
component, its license, and — where applicable — what Brun changed.

---

## guacd (Apache Guacamole Server)

- **Project:** https://guacamole.apache.org/
- **Source:** https://github.com/apache/guacamole-server
- **License:** Apache License, Version 2.0
- **Copyright:** Apache Software Foundation

Used by Brun as the underlying protocol proxy engine that provides
SSH, RDP, VNC, and Telnet access. Distributed and run as the official,
unmodified `guacamole/guacd` container image — Brun does not build,
modify, or redistribute this component itself; it's pulled directly
from its official source at install time.

## guacamole-lite

- **Project:** https://github.com/vadimpronin/guacamole-lite
- **Source:** https://github.com/vadimpronin/guacamole-lite
- **License:** Apache License, Version 2.0
- **Copyright:** guacamole-lite contributors

Used by Brun as the Node.js bridge between the browser-facing
WebSocket tunnel and `guacd`. This package itself bundles a copy of
the official Apache Guacamole JavaScript protocol parser (see its own
NOTICE for details). Used unmodified by Brun.

## guacamole-common-js

- **Project:** https://guacamole.apache.org/
- **Source:** Derived from https://github.com/apache/guacamole-client
- **License:** Apache License, Version 2.0
- **Copyright:** Apache Software Foundation

Used by Brun to render the remote session display in the browser and
to play back recorded sessions.

**Modification:** Brun patches one function in this library at serve
time (the `SessionRecording` constructor) to fix an upstream bug where
the Blob-based playback source is never assigned to the internal
`recordingBlob` variable — without this fix, recorded session playback
does not work at all. No other functional change is made. See the
`/vendor/guacamole-common.js` route in this project's source for the
exact patch applied.

---

For all three components above, a full copy of the Apache License,
Version 2.0 is available at: http://www.apache.org/licenses/LICENSE-2.0

See each project's own LICENSE and NOTICE files (linked above) for
complete copyright and attribution details. This file covers only
these Apache-licensed dependencies — it does not change the license
terms stated in [README.md](README.md#license) for the rest of this
repository (MIT) or for the Brun application image itself
(proprietary, distributed as a prebuilt image).
