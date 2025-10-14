#!/bin/sh

cpu() {
	cpu="$(grep -o "^[^ ]*" /proc/loadavg)"
}

memory() {
	memory="$(free -h | sed -n "2s/\([^ ]* *\)\{2\}\([^ ]*\).*/\2/p")"
}

disk() {
	disk="$(df -h | awk 'NR==2{print $4}')"
}

datetime() {
	datetime="$(date "+   %F %A vecka %V | 󰥔  %R")"
}

bat() {
	read -r bat_status </sys/class/power_supply/BAT0/status
	read -r bat_capacity </sys/class/power_supply/BAT0/capacity
	bat="$bat_status $bat_capacity%"
}

vol() {
	vol="$([ "$(pamixer --get-mute)" = "false" ] && printf "%s%%" "$(pamixer --get-volume)" || printf '-')"
}

display() {
	echo "all status [$vol] [$memory $cpu $disk] | 󰁹 $bat | $datetime" >"$FIFO"
}

printf "%s" "$$" > "$XDG_RUNTIME_DIR/status_pid"
FIFO="$XDG_RUNTIME_DIR/sandbar"
[ -e "$FIFO" ] || mkfifo "$FIFO"
sec=0

while true; do
	sleep 1 &
	wait && {
		[ $((sec % 15)) -eq 0 ] && memory
		[ $((sec % 15)) -eq 0 ] && cpu
		[ $((sec % 15)) -eq 0 ] && disk
		[ $((sec % 60)) -eq 0 ] && bat
		[ $((sec % 5)) -eq 0 ] && vol
		[ $((sec % 5)) -eq 0 ] && datetime

		[ $((sec % 5)) -eq 0 ] && display

		sec=$((sec + 1))
	}
done
