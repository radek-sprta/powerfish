set -U git_status_clean yellow
set -U git_status_dirty red

function git_branch_status -d 'See if there is anything to commit'
	if test (git status 2> /dev/null ^&1 | tail -n1) != 'nothing to commit, working tree clean'
   		echo $git_status_dirty
	else
   		echo $git_status_clean
	end
end

function fish_prompt --description 'Write out the prompt'

    # Initialize colors
    set -U fish_color_user 444
    set -U fish_color_local green
    set -U fish_color_remote red
    set -U fish_color_status yellow
	set -U fish_color_cwd (set_color black -b blue)
	set -l color_cwd
	set -l normal (set_color white)

	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end
	if not set -q __fish_prompt_git_branch 
		set __fish_prompt_git_branch $normal(git branch ^/dev/null | grep \* | sed 's/* //')
	end

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
            set fish_color_host green
        end
    case '*'
        if set -q fish_color_remote
            set fish_color_host $fish_color_remote
        else
            set fish_color_host red
        end
    end
            

	echo -n -s $normal (set_color -b $fish_color_user) "$USER"\
(set_color $fish_color_user -b $fish_color_host) $normal (set_color -b $fish_color_host) "$__fish_prompt_hostname"\
(set_color $fish_color_host -b blue)  $color_cwd (prompt_pwd)\
(set_color blue -b (git_branch_status))  "$__fish_prompt_git_branch"\
(set_color (git_branch_status) -b normal)' ' $normal
end
