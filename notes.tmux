split panes
	C-b %
	C-b "

Navigating panes
	C-b <arrow key>

CLosing Panes
	exit
	C-d

pane size
	C-b z	// full or back to origin
	C-b Alt-<arrow key> // Resize pane in direction of <arrow key>

Same command for all panes
	`Ctrl-b` then ":setw synchronize-panes"

	to turnoff
	`Ctrl-b` then ":setw synchronize-panes off"
scrolling
	C-b [
		fn-<down> // page down
	q	// quit

	size / run it on non-tmux env
		tmux set-option -g history-limit 5000
		tmux set-option history-limit 5000 \; new-window
		tmux set-option -g history-limit 5000 \; new-session 

		tmux show-options -g
Creating WIndows
	C-b c
Switch window
	C-b p
	C-b n
	C-b <number>

	C-b , // rename the current window
Session Handling
	Detach
		C-b d
		C-b D // give choice
	tmux ls
	tmux attach -t 0

	Namespace
	tmux new -s <name>
	tmux rename-session -t 0 <new name>
	tmux attach -t <name>

Help
	C-b ?
