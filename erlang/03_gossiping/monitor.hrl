-record(monitor_data, {members, status}).
-record(member, {host, tag, kind=agent}).
-record(status, {status=up, last_heartbeat}).