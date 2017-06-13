function fish_prompt --description 'Write out the prompt'

	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	set -l normal (set_color normal)

    # initialize our new variables
    set -U fish_color_user -o magenta
    set -U fish_color_local -o green
    set -U fish_color_remote -o red
    set -U fish_color_status -o yellow
	set -l color_cwd

	switch $USER
	case root toor
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		else
			set color_cwd $fish_color_cwd
		end
		set suffix '#'
	case '*'
		set color_cwd $fish_color_cwd
		set suffix '>'
	end

    # Hack; Use different colors for local and remote hosts
    switch $__fish_prompt_hostname
    case Ravenloft
        if set -q fish_color_local
            set fish_color_host $fish_color_local
        else
            set fish_color_host -o green
        end
    case '*'
        if set -q fish_color_remote
            set fish_color_host $fish_color_remote
        else
            set fish_color_host -o red
        end
    end
            

	echo -n -s (set_color $fish_color_user) "$USER" $normal @ (set_color $fish_color_host) "$__fish_prompt_hostname" $normal ' ' (set_color $color_cwd) (prompt_pwd) (set_color $fish_color_status) (__fish_vcs_prompt) $normal "> "
end
