-record(monitor_data, {members, status, messages}).
-record(member, {host, tag, kind=agent}).
-record(status, {status=up, last_heartbeat}).

-record(message, {tries=0, known_by=[], sent_to=[]}).
