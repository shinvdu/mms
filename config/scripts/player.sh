#!/bin/bash
cd /mnt/app/wgcloud
PATH=$PATH:/usr/local/ruby/bin
NAME=wgcloud_1
DESC="Unicorn app for wgcloud"

do_start(){
	RAILS_ENV=production bundle exec unicorn_rails -c config/unicorn/player_process_1.rb -D
}

do_stop(){
	kill -QUIT `cat tmp/pids/player_unicorn_1.pid`
}

do_reload(){
	kill -HUP `cat tmp/pids/player_unicorn_1.pid`
}

case "$1" in
	start)
		echo -n "Starting $DESC: "
		do_start
		echo "$NAME."
		;;
	stop)
		echo -n "Stopping $DESC: "
		do_stop
		echo "$NAME."
		;;
	restart)
		echo -n "Restarting $DESC configuration: "
		do_stop
		do_start
		echo "$NAME."
		;;
	reload)
		echo -n "Reloading $DESC configuration: "
		do_reload
		echo "$NAME."
		;;
		  *)
		    echo "Usage: $NAME {start|stop|restart|reload}" >&2
		    exit 1
		    ;;
esac
