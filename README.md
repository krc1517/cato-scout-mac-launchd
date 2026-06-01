# cato-scout-mac-launchd

Customer-ready macOS `launchd` package for running Cato AI Scout on a recurring schedule using a bearer token stored in a local root-only file.


This package installs Cato AI Scout on macOS with a root-owned `launchd` job that:

- runs once at load
- runs every 6 hours
- uses a bearer token stored in a file
- prevents overlapping runs with a lock directory
- writes logs to `/var/log`

## Files in this package

- `install-cato-scout-launchd.sh` - installer/uninstaller helper
- `cato-scout-refresh.sh` - root-run wrapper script
- `com.catonetworks.ai-scout-refresh.plist` - `launchd` daemon definition

## Why use `launchd` on macOS instead of cron?

On macOS, `launchd` is the native system service manager and is the recommended way to run recurring background tasks.

For Cato AI Scout, `launchd` is preferred over cron because it:

- is the Apple-supported scheduling mechanism for system services
- runs reliably at startup with `RunAtLoad`
- works cleanly as a root-owned daemon in `/Library/LaunchDaemons`
- provides easier status and troubleshooting with `launchctl`
- supports straightforward stdout/stderr log files
- avoids common cron issues on macOS such as limited environment variables and inconsistent execution context

Cron can still run scheduled commands, but for a recurring security agent installation or refresh task on macOS, `launchd` is generally more reliable, easier to support, and more aligned with Apple’s platform conventions.

## Quick install snippet

Create the token file:

```sh
sudo mkdir -p /etc/cato-scout
sudo chmod 700 /etc/cato-scout
sudo sh -c '''printf "%s\n" "aim-REPLACE_WITH_BEARER_TOKEN" > /etc/cato-scout/token'''
sudo chown root:wheel /etc/cato-scout/token
sudo chmod 600 /etc/cato-scout/token
```

Install the recurring service:

```sh
sudo sh ./install-cato-scout-launchd.sh install
```

## Daily schedule variant

If you prefer a daily 3:00 AM schedule instead of every 6 hours, replace the default plist in this package with:

- `com.catonetworks.ai-scout-refresh.daily-3am.plist`

Then rename it to:

- `com.catonetworks.ai-scout-refresh.plist`

before running the installer.

## Token file

Create this file and paste the bearer token into it:

- `/etc/cato-scout/token`

Required permissions:

- directory: `700`
- token file: `600`
- owner: `root:wheel`

Example:

```sh
sudo mkdir -p /etc/cato-scout
sudo chmod 700 /etc/cato-scout
sudo sh -c 'printf "%s\n" "aim-REPLACE_WITH_BEARER_TOKEN" > /etc/cato-scout/token'
sudo chown root:wheel /etc/cato-scout/token
sudo chmod 600 /etc/cato-scout/token
```

## Install

From this package directory:

```sh
sudo sh ./install-cato-scout-launchd.sh install
```

This installs:

- `/usr/local/sbin/cato-scout-refresh.sh`
- `/Library/LaunchDaemons/com.catonetworks.ai-scout-refresh.plist`

And then loads the daemon.

## One-command health check

Use this to inspect the service state and the latest log/error output with a single sudo prompt:

```sh
sudo sh -c '''echo "--- SERVICE ---"; launchctl print system/com.catonetworks.ai-scout-refresh 2>/dev/null | egrep "state =|last exit code =|pid =|runs =|last fire time =|program =" || true; echo; echo "--- LAST LOG ---"; tail -50 /var/log/cato-scout-refresh.log 2>/dev/null || true; echo; echo "--- LAST ERR ---"; tail -50 /var/log/cato-scout-refresh.err 2>/dev/null || true'''
```

## One-command clean test run

Use this to clear the logs, force a fresh Scout run, wait briefly, and print only the new output:

```sh
sudo sh -c '''> /var/log/cato-scout-refresh.log; > /var/log/cato-scout-refresh.err; launchctl kickstart -k system/com.catonetworks.ai-scout-refresh; sleep 12; echo "--- LOG ---"; cat /var/log/cato-scout-refresh.log; echo; echo "--- ERR ---"; cat /var/log/cato-scout-refresh.err'''
```

A healthy run should show the following in `LOG`:

- `Installed version is up to date.`
- `Endpoint scan completed successfully`
- `Detailed information reported successfully`

And `ERR` should be empty.

## Verify

```sh
sudo launchctl print system/com.catonetworks.ai-scout-refresh
sudo tail -100 /var/log/cato-scout-refresh.log
sudo tail -100 /var/log/cato-scout-refresh.err
```

## Force a run now

```sh
sudo launchctl kickstart -k system/com.catonetworks.ai-scout-refresh
```

## Remove old Scout cron entries

If an older cron-based install exists, remove Scout-related entries:

```sh
TMP1="$(mktemp)"
TMP2="$(mktemp)"

(crontab -l 2>/dev/null | grep -viE 'ai-scout|api\.aisec\.catonetworks\.com/ai-scout|cato-scout-refresh' || true) > "$TMP1"

sudo sh -c "(crontab -l -u root 2>/dev/null | grep -viE 'ai-scout|api\\.aisec\\.catonetworks\\.com/ai-scout|cato-scout-refresh' || true) > '$TMP2'"

[ -s "$TMP1" ] && crontab "$TMP1" || crontab -r 2>/dev/null || true
sudo sh -c "[ -s '$TMP2' ] && crontab -u root '$TMP2' || crontab -r -u root 2>/dev/null || true"

rm -f "$TMP1" "$TMP2"
```

## Uninstall

```sh
sudo sh ./install-cato-scout-launchd.sh uninstall
```

## Notes

- This package assumes the official installer endpoint is:
  - `https://api.aisec.catonetworks.com/ai-scout/installation.sh`
- The bearer token is read from `/etc/cato-scout/token`
- The job runs every 6 hours via `StartInterval=21600`
- Logs go to:
  - `/var/log/cato-scout-refresh.log`
  - `/var/log/cato-scout-refresh.err`
