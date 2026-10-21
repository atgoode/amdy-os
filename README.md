# amdy-os

The OS image for **AMDY** (Ryzen 9 9900X3D, RX 9070 XT): [Bazzite-DX](https://github.com/ublue-os/bazzite) plus the system-level pieces an agent-run machine needs. Built from [ublue-os/image-template](https://github.com/ublue-os/image-template); GitHub Actions builds and signs it daily and on every push to `main`.

| Added on top of Bazzite-DX | Where |
|---|---|
| NetBird client (official RPM, repo disabled after install) + service unit | `build_files/build.sh`, `system_files/etc/systemd/system/netbird.service` |
| SSH: keys only, no root, user `andrew` only from NetBird (`100.64.0.0/10`), Mac key baked in | `system_files/etc/ssh/` |
| Passwordless sudo for agents, limited to `bootc` status/upgrade/rollback/switch-to-this-image, reboot/poweroff, and read-only checks | `system_files/etc/sudoers.d/50-agents` |
| `smartmontools`, `dmidecode`, `nvtop`, `socat` | `build_files/build.sh` |

Not in here, by design: models, llama.cpp, ComfyUI and the amdy-llm controller (user-level, in containers; see the private `amdy-llm` repo and its `MIGRATION-bazzite.md`). No secrets: the image is public.

## Using it

```bash
sudo bootc switch ghcr.io/atgoode/amdy-os:latest   # from any Bazzite / bootc install
sudo bootc upgrade                                # later updates (also automatic)
sudo bootc rollback                               # back to the previous image
```

After the first boot: `sudo netbird up --management-url https://netbird.thegoode.cloud --setup-key <key>` once. From then on agents reach it over NetBird.

Signing: `cosign.pub` is the public key; the private key is the `SIGNING_SECRET` Actions secret only.
