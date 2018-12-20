# COLOUR
tm_color_active=colour106
tm_color_inactive=colour241
tm_color_feature=colour149
tm_color_sysinfo=colour110

# separators
tm_separator_left_bold=""
tm_separator_left_thin=""
tm_separator_right_bold=""
# tm_separator_right_thin=" ▣ ♟"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 2


# default statusbar colors
set-option -g status-fg $tm_color_active
set-option -g status-bg default
set-option -g status-attr default

# set-option -g status-bg  colour236
# default window title colors
set-window-option -g window-status-fg $tm_color_inactive
set-window-option -g window-status-bg default
set -g window-status-format "[#I,#F,#W]"

# active window title colors
set-window-option -g window-status-current-fg $tm_color_active
set-window-option -g window-status-current-bg  default
set-window-option -g  window-status-current-format "[#I,#F,#W]"

# pane border
set-option -g pane-border-fg $tm_color_inactive
set-option -g pane-active-border-fg $tm_color_active

# message text
set-option -g message-bg default
set-option -g message-fg $tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_active

# tm_sysinfo=" #[fg=$tm_color_sysinfo,bright]#(tmux-mem-cpu-load -m 2 -g 0 -a 1)"
tm_date="#[fg=colour230]%d-%b#[fg=colour251] %l:%M"
tm_pwd="#[fg=colour230,bold]#{pane_current_path}"
tm_host="#[fg=$tm_color_feature,bold]@Anoop"
tm_session_name="#[fg=$tm_color_feature]$tm_separator_left_thin#S"
# tm_separator_right_thin=" ▣ ♟"


#settings status bar
set -g status-right $tm_session_name' '$tm_date #$tm_separator_right_thin
set -g status-left  ''

# set-option -g status-position top
set -wg mode-style bg=cyan,fg=black
