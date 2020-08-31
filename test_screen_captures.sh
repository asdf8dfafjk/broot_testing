DEFAULT='\033[00m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

function SetupTestEnv
{
	mkdir -p a/m/x a/m/y
	for i in $(seq 1 120)
	do
		touch a/m/x/$i.txt
	done

	echo "broot is a file manager." > a/m/x/112.txt
}

BROOT_TMUX_SESSION="broot_test_$$"
BROOT_BINARY=broot


CAPTURE_DIR="/tmp/$$.BROOT.CAPTURES"
echo -e "$YELLOW Captures in $CAPTURE_DIR"
mkdir -p $CAPTURE_DIR
FAILURE=false

function capture_compare
{
	echo -e "$YELLOW Test case $1 $DEFAULT"
	CAPTURE_FILE="$CAPTURE_DIR/$1"

	tmux capture-pane -p -e -t $BROOT_TMUX_SESSION > $CAPTURE_FILE
	if ! diff --side-by-side --suppress-common-lines $CAPTURE_FILE master/$1 
	then
		echo -e $RED "❌ $1"
		FAILURE=true
	else 
		echo -e $GREEN "✅ $1"
	fi
	echo -e "$DEFAULT"
}

function normalize_file_name()
{
	INPUT="$1"
	OUTPUT=${INPUT/$PWD/}
	echo $OUTPUT
}

function clipboard_compare_file_name()
{
	EXPECTED_CLIPBOARD_TEXT=$1
	NORMALIZED=$(normalize_file_name $(xsel -b))

	if [ "$NORMALIZED" = "$EXPECTED_CLIPBOARD_TEXT" ]
	then
		echo -e $GREEN "✅ Clipboard as expected: $1"
	else 
		echo -e $RED "❌ Clipboard, got: $(xsel -b) expected (after normalization): $1"
		FAILURE=true
	fi
	echo -e "$DEFAULT"
}

function SendKeysToTmuxSession
{
	tmux send-keys -t $BROOT_TMUX_SESSION $@
	sleep 0.5	
}

function TestCopy
{
	SendKeysToTmuxSession :copy_path ENTER
	clipboard_compare_file_name "/a/m/x/34.txt"
	
	SendKeysToTmuxSession DOWN DOWN ENTER
	clipboard_compare_file_name "/a/m/x/36.txt"

	SendKeysToTmuxSession ESCAPE

	SendKeysToTmuxSession UP UP M-c
	clipboard_compare_file_name "/a/m/x/98.txt"
}


tmux -u new-session -d -x 50 -y 50 -s $BROOT_TMUX_SESSION
trap "tmux kill-session -t $BROOT_TMUX_SESSION; exit" SIGINT SIGTERM


echo "Setting up test environment"
SetupTestEnv

echo "Starting tests"

# Initial View
SendKeysToTmuxSession 'unset' SPACE 'RPROMPT' ENTER
SendKeysToTmuxSession export SPACE PS1=$ ENTER
SendKeysToTmuxSession clear ENTER
SendKeysToTmuxSession $BROOT_BINARY ENTER

capture_compare initial


# Folder Pane, open
SendKeysToTmuxSession DOWN
SendKeysToTmuxSession DOWN
SendKeysToTmuxSession C-Right

capture_compare folder_pane_open

# Folder Pane, closed
SendKeysToTmuxSession Escape

capture_compare folder_pane_closed

# Fuzzy file search
SendKeysToTmuxSession 112

capture_compare file_fuzzy

# File contents
SendKeysToTmuxSession C-Right

capture_compare file_contents

SendKeysToTmuxSession Escape
SendKeysToTmuxSession Escape

# Page down
SendKeysToTmuxSession x
SendKeysToTmuxSession ENTER
SendKeysToTmuxSession PageDown
SendKeysToTmuxSession PageDown

capture_compare page_down

# Page up
SendKeysToTmuxSession PageUp

capture_compare page_up


# Copy
TestCopy

# Print path
SendKeysToTmuxSession :print_path ENTER

capture_compare print_path

sleep 2
tmux kill-session -t $BROOT_TMUX_SESSION


if $FAILURE
then
	echo -e "$RED There were failures, see $CAPTURE_DIR"
fi

rm -rf a
