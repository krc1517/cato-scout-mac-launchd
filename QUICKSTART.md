# Cato AI Scout macOS Quickstart

## What this does

This installs Cato AI Scout on macOS as a root-owned `launchd` service that:

- runs at startup
- re-runs every 6 hours
- uses your bearer token from a local file
- avoids overlapping runs

## 1) Put your bearer token in a file

Run:

```sh
sudo mkdir -p /etc/cato-scout
sudo chmod 700 /etc/cato-scout
sudo sh -c 'printf "%s\n" "aim-REPLACE_WITH_YOUR_BEARER_TOKEN" > /etc/cato-scout/token'
sudo chown root:wheel /etc/cato-scout/token
sudo chmod 600 /etc/cato-scout/token
```

## 2) Install the service

From this folder, run:

```sh
sudo sh ./install-cato-scout-launchd.sh install
```

## 3) Verify

```sh
sudo launchctl print system/com.catonetworks.ai-scout-refresh
sudo tail -50 /var/log/cato-scout-refresh.log
sudo tail -50 /var/log/cato-scout-refresh.err
```

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

## 4) Force a run now

```sh
sudo launchctl kickstart -k system/com.catonetworks.ai-scout-refresh
```

## 5) Uninstall

```sh
sudo sh ./install-cato-scout-launchd.sh uninstall
```

## Installed locations

- Script: `/usr/local/sbin/cato-scout-refresh.sh`
- LaunchDaemon: `/Library/LaunchDaemons/com.catonetworks.ai-scout-refresh.plist`
- Token file: `/etc/cato-scout/token`
- Logs:
  - `/var/log/cato-scout-refresh.log`
  - `/var/log/cato-scout-refresh.err`

## Daily schedule variant

If you want a once-per-day schedule at 3:00 AM instead of every 6 hours, use:

- `com.catonetworks.ai-scout-refresh.daily-3am.plist`

Rename it to `com.catonetworks.ai-scout-refresh.plist` before installing.
