#!/bin/sh

#        # Status bar
#        ( while (
#            D="$(date "+   %F %A vecka %V | 󰥔  %R" || true)"
#            B=" 󰁹 $(acpi | awk -F ',' '{print $2}' || true)"
#            V="󰖀 $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk -F ':' '{print $2 * 100 "%"}' || true)"
#            echo "all status $V | $B | $D"
#        ); do sleep 15; done ) | sandbar ${if config.stylix.enable == true then (
#             " -font \"${config.stylix.fonts.sansSerif.name} ${toString config.stylix.fonts.sizes.desktop}\""
#           + " -inactive-bg-color \"#" + config.lib.stylix.colors.base01 + "\""
#           + " -inactive-fg-color \"#" + config.lib.stylix.colors.base05 + "\""
#           + " -active-bg-color   \"#" + config.lib.stylix.colors.base02 + "\""
#           + " -active-fg-color   \"#" + config.lib.stylix.colors.base05 + "\""
#           + " -urgent-fg-color   \"#" + config.lib.stylix.colors.base04 + "\""
#           + " -urgent-bg-color   \"#" + config.lib.stylix.colors.base09 + "\""
#           + " -title-fg-color    \"#" + config.lib.stylix.colors.base05 + "\""
#           + " -title-bg-color    \"#" + config.lib.stylix.colors.base01 + "\""
#         ) else ""} &
#

cpu() {
	cpu="$(grep -o "^[^ ]*" /proc/loadavg)"
}

memory() {
	memory="$(free -h | sed -n "2s/\([^ ]* *\)\{2\}\([^ ]*\).*/\2/p")"
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
	echo "all status 󰖀 $vol  |     $memory |     $cpu |  󰁹 $bat |  $datetime" >"$FIFO"
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
		[ $((sec % 60)) -eq 0 ] && bat
		[ $((sec % 5)) -eq 0 ] && vol
		[ $((sec % 5)) -eq 0 ] && datetime

		[ $((sec % 5)) -eq 0 ] && display

		sec=$((sec + 1))
	}
done
