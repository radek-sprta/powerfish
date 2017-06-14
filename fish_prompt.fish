# Characters
set -g SEPARATOR ''

set -U git_status_clean yellow
set -U git_status_dirty red

function git_branch_status -d 'See if there is anything to commit'
	if test (git status 2> /dev/null ^&1 | tail -n1) != 'nothing to commit, working tree clean'
   		echo $git_status_dirty
	else
   		echo $git_status_clean
	end
end

function __prompt_segment -d 'Draw prompt segment' 
	set -l fg $argv[1]
	set -l bg $argv[2]	
	if not set -q current_background
		set -g current_background 444
	end
	echo -n -s (set_color $current_background -b $bg) $SEPARATOR (set_color $fg -b $bg)
	set current_background $bg
end

function __is_remote -d 'Check if shell is local or remote'
    switch (ps --format comm= --pid %self)
    case sshd
        echo 'remote'
    case '*'
        echo 'local'
    end
end

function __is_root -d 'Check if user is root'
	switch $USER
	case root toor
        echo 'root'
	case '*'
        echo 'normal'
	end
end

function fish_prompt --description 'Write out the prompt'

    # Initialize colors
    set -U fish_color_bg_normal 444
    set -U fish_text_light white
    set -U fish_text_dark black
    set -U fish_color_user $fish_color_bg_normal
    set -U fish_color_root red
    set -U fish_color_local $fish_color_bg_normal
    set -U fish_color_remote yellow
	set -U fish_color_cwd blue
    set -U fish_color_root red
	set -l color_cwd
	set -l normal (set_color white)

	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end
	if not set -q __fish_prompt_git_branch 
		set __fish_prompt_git_branch $normal(git branch ^/dev/null | grep \* | sed 's/* //')
	end
    # Use different colors for local and remote hosts
    if not set -q __fish_prompt_host_color
        switch (__is_remote)
        case remote
            set __fish_prompt_host_color $fish_color_remote
        case local
            set __fish_prompt_host_color $fish_color_local
        end
    end
    # Use different colors for normal user and root
    switch (__is_root)
    case root
        set fish_color_user $fish_color_root
    case normal
        set fish_color_user $fish_color_bg_normal
    end

    # TODO Nice boundary between user and local
    # TODO Add status
    # TODO Switch font color as well, not just background
	echo -n -s (set -g current_background $fish_color_bg_normal) (set_color $fish_text_light -b $fish_color_user) "$USER"\
        " at"\
        (__prompt_segment $fish_text_light $__fish_prompt_host_color)"$__fish_prompt_hostname"\
        (__prompt_segment $fish_text_dark $fish_color_cwd) (prompt_pwd)\
        (__prompt_segment $fish_text_dark (git_branch_status)) "$__fish_prompt_git_branch"\
        (__prompt_segment (git_branch_status) normal)
        set_color normal
end
