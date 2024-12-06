# bin/bash

max_length=50
current_dir=$(tmux display-message -p -F "#{pane_current_path}")

if [[ ${#current_dir} -gt $max_length ]]; then
	echo "$(basename "${current_dir:0:$max_length}")..."
else
	echo "$(basename "$current_dir")"
fi
