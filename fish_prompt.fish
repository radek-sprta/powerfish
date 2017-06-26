# Characters
# If Powerline modified fonts are installed, use them fir nicer output
if not set -q __powerline_font_checked
    set -U __powerline_font_checked (locate powerline)
end
if test -n $powerline_font_checked
    set -U SEPARATOR ''
else
    set -U SEPARATOR ''
end
set -g FAILED '✘'
set -g BRANCH ''

# Initialize colors
set -U fish_color_bg_normal 444
set -U fish_text_light white
set -U fish_text_dark black
set -U git_color_untracked red
set -U git_color_dirty yellow
set -U git_color_clean green
set -U fish_color_venv magenta
set -U fish_color_user $fish_color_bg_normal
set -U fish_color_root red
set -U fish_color_remote yellow
set -U fish_color_cwd blue


function __prompt_segment -d 'Draw prompt segment'
	set -l fg $argv[1]
	set -l bg $argv[2]
	if not set -q current_background
		set -g current_background $fish_color_bg_normal
	end
	echo -n -s (set_color $current_background -b $bg) $SEPARATOR (set_color $fg -b $bg)
	set current_background $bg
end


function __venv_prompt -d "Write out virtual environment prompt"
    if test -n "$VIRTUAL_ENV"
        echo -n -s (set -g current_background $fish_color_venv)\
                   (set_color $fish_text_light -b $fish_color_venv)" "(basename $VIRTUAL_ENV)" "
    else
        echo ''
    end
end


function __user_prompt -d "Write out the user prompt"

    # Status of last command; calculate only once
    if not set -q __fish_prompt_status
        if test $last_status -ne 0
            set __fish_prompt_status (set_color red -b $fish_color_user)"$FAILED "
        end
    end

    # Use different colors for normal user and root
    set -l user_status_color
    set -l user_status_text $fish_text_light
	switch $USER
	case root toor
        set user_status_color $fish_color_root
    case '*'
        set user_status_color $fish_color_user
    end

    # If we are in virtual environment, get a properly colored prompt
    if test -n "$VIRTUAL_ENV"
        echo (__prompt_segment $user_status_text $user_status_color)
    else
        echo (set -g current_background $user_status_color)
    end
    echo -n -s (set_color -b $user_status_color)" $__fish_prompt_status"\
               (set_color $user_status_text)"$USER "
end


function __hostname_prompt -d "Write out the hostname prompt"

    # Hostname, calculate just once
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

    # Only show remote hosts
    set -l ppid (ps --format ppid= --pid %self | tr -d '[:space:]')
    switch (ps --format comm= --pid $ppid)
    case sshd
        echo (__prompt_segment $fish_text_dark $fish_color_remote)" at $__fish_prompt_hostname "
    case '*'
        echo ''
    end
end


function __cwd_prompt -d "Write out current working directory"
    echo (__prompt_segment $fish_text_dark $fish_color_cwd)" "(prompt_pwd)" "
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
        # First field is total count
        echo (echo $argv[1] | cut -d ' ' -f 1)
    end

    if test -n (__git_branch_name)
        if test -n (__is_git_dirty)
            # Get all info about branch
            for i in (git status --porcelain | cut -c 1-2 | sort | uniq -c | string trim -l)
                # Third field is status flag
                switch (echo $i | string sub -s 3)
                    case "*[ahead *"
                        set git_flags "$git_flags ⬆ "(__count $i)
                    case "*behind *"
                        set git_flags "$git_flags ⬇ "(__count $i)
                    case "*M"
                        set git_flags "$git_flags ✚ "(__count $i)
                    case "U*"
                        set git_flags "$git_flags ✖ "(__count $i)
                    case "M*"
                        set git_flags "$git_flags ● "(__count $i)
                    case "A*"
                        set git_flags "$git_flags ● "(__count $i)
                    case "*R*"
                        set git_flags "$git_flags ➜ "(__count $i)
                    case "*U"
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
        # Not in git repo, don't print anything, just set proper colors
        echo (__prompt_segment $fish_color_cwd normal)
    end
end

function fish_prompt --description 'Write out the prompt'

    # Save the last status
    set -g last_status $status

    # Disable virtual envirnment prompt; we have our own override
    set -U VIRTUAL_ENV_DISABLE_PROMPT 1

	echo -n -s \
        (__venv_prompt)\
        (__user_prompt)\
        (__hostname_prompt)\
        (__cwd_prompt)\
        (__git_prompt)\
        (set_color normal)" "
end
