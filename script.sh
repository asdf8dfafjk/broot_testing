DEFAULT='\033[00m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'


CAPTURE_DIR="/tmp/$$.BROOT.CAPTURES"
mkdir -p $CAPTURE_DIR
FAILURE=false

function capture_compare
{
	echo -e "$YELLOW Test case $1 $DEFAULT"
	CAPTURE_FILE="$CAPTURE_DIR/$1.capture"

	tmux capture-pane -p -e > $CAPTURE_FILE
	if ! diff $CAPTURE_FILE master/$1.master 
	then
		echo -e $RED "❌ $1"
		FAILURE=true
	else 
		echo -e $GREEN "✅ $1"
	fi
	echo -e "$DEFAULT"
}


tmux -u new-session -d -x 50 -y 50 -s broot_test

# Initial View
tmux send -t broot_test broot ENTER
sleep 0.5
capture_compare initial


# Folder Pane, open
tmux send-keys -t broot_test DOWN
sleep 0.5
tmux send-keys -t broot_test DOWN
sleep 0.5
tmux send-keys -t broot_test C-Right
sleep 0.5
capture_compare folder_pane_open

# Folder Pane, closed
tmux send-keys -t broot_test Escape
sleep 0.5
capture_compare folder_pane_closed

# Fuzzy file search
tmux send-keys -t broot_test 112
sleep 0.5
capture_compare file_fuzzy

# File contents
tmux send-keys -t broot_test C-Right
sleep 0.5
capture_compare file_contents

tmux send-keys -t broot_test Escape
sleep 0.5
tmux send-keys -t broot_test Escape
sleep 0.5

# Page down
tmux send -t broot_test x
sleep 0.5
tmux send -t broot_test ENTER
sleep 0.5
tmux send -t broot_test PageDown
sleep 0.5
tmux send -t broot_test PageDown
sleep 0.5
capture_compare page_down

# Page up
tmux send -t broot_test PageUp
sleep 0.5
capture_compare page_up

# Print path
tmux send -t broot_test :print_path ENTER
sleep 0.5
capture_compare print_path


tmux kill-session -t broot_test

if [ $FAILURE ]
then
	echo "There were failures, see $CAPTURE_DIR"
fi
