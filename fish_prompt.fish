# Characters
set -g SEPARATOR ''
set -g OK '✔'
set -g FAILED '✘'
set -g BRANCH ''

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

function __git_prompt -d "Write out the git prompt"

    function __is_git_dirty -d 'Check if repo is dirty'
        echo (git status -s --ignore-submodules=dirty ^/dev/null)
    end

    function __git_branch_name -d 'Get branch name'
        echo (git branch ^/dev/null | grep \* | sed 's/* //')
    end

    function __set_git_color -d 'Set color depending on the tree status'
        if test -n (__is_git_dirty)
            # Check if there are untracked files
            set -l untracked (git ls-files --other --exclude-standard 2> /dev/null)
            if test -n "$untracked"
                set -g git_status_color $git_color_untracked
                set -g git_status_text $fish_text_light
            else
                set -g git_status_color $git_color_dirty
                set -g git_status_text $fish_text_dark
            end
        else
            set -g git_status_color $git_color_clean
            set -g git_status_text $fish_text_dark
        end
    end

    function __count -d 'Count the various git statuses'
        echo (echo $argv[1] | cut -d ' ' -f 1)
    end

    if test -n (__git_branch_name)
        if test -n (__is_git_dirty)
            for i in (git status --porcelain | cut -c 1-2 | sort | uniq -c | sed -e 's/^[[:space:]]*//')
                switch (echo $i | cut -d ' ' -f 2)
                    case "*[ahead *"
                        set git_flags "$git_flags ⬆ "(__count $i)
                    case "*behind *"                  
                        set git_flags "$git_flags ⬇ "(__count $i)
                    case "*A*"                         
                        set git_flags "$git_flags ✚ "(__count $i)
                    case " D"                         
                        set git_flags "$git_flags ✖ "(__count $i)
                    case "*M*"                        
                        set git_flags "$git_flags ● "(__count $i)
                    case "*R*"                        
                        set git_flags "$git_flags ➜ "(__count $i)
                    case "*U*"                        
                        set git_flags "$git_flags ═ "(__count $i)
                    case "??"                        
                        set git_flags "$git_flags … "(__count $i)
                end
            end
        else
            set git_flags ""
        end
        __set_git_color
        echo -n -s (__prompt_segment $git_status_text $git_status_color)\
                   " $BRANCH "(__git_branch_name)"$git_flags "\
                   (__prompt_segment $git_status_color normal)
    else
        echo (__prompt_segment $fish_color_cwd normal)
    end
end

function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # Initialize colors
    set -U fish_color_bg_normal 444
    set -U fish_text_light white
    set -U fish_text_dark black
    set -U git_color_untracked red
    set -U git_color_dirty yellow
    set -U git_color_clean green
    set -U fish_color_user $fish_color_bg_normal
    set -U fish_color_root red
    set -U fish_color_local $fish_color_bg_normal
    set -U fish_color_remote yellow
	set -U fish_color_cwd blue
    set -U fish_color_root red
	set -l color_cwd
	set -l normal (set_color white)

	# Just calculate this once, to save a few cycles when displaying the prompt
    
    # Status of last command
    if not set -q __fish_prompt_status
        if test $last_status -ne 0
            set __fish_prompt_status (set_color red -b $fish_color_user)"$FAILED "
        end
    end
    # Hostname
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
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

	echo -n -s (set -g current_background $fish_color_user) "$__fish_prompt_status"\
        (set_color $fish_text_light -b $fish_color_user) "$USER"\
        (__prompt_segment $fish_text_light $__fish_prompt_host_color)"$__fish_prompt_hostname"\
        (__prompt_segment $fish_text_dark $fish_color_cwd) (prompt_pwd)\
        (__git_prompt)\
        (set_color normal)" "
end
