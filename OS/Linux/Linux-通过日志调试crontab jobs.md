# Linux 启用 crontab 日志

You can enable logging for cron jobs in order to track problems.

You need to edit the `/etc/rsyslog.conf or /etc/rsyslog.d/50-default.conf` (on Ubuntu) file and make sure you have the following line uncommented or add it if it is missing:

```ini
cron.*                         /var/log/cron.log
```

Then restart `rsyslog` and `cron`:

```shell
sudo service rsyslog restart
sudo service cron restart
```

Cron jobs will log to `/var/log/cron.log` .
