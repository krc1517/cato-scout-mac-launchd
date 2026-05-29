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
