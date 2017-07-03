# Characters
if not set -q __powerfish_characters_initialized
    set -U __powerfish_characters_initialized
    set -U FAILED '✘'
    set -U BRANCH ''
    set -U UNTRACKED '…'
    set -U MODIFIED '✚'
    set -U STAGED '●'
    set -U CONFLICTED '✖'
    set -U STASHED '⚑'
end

function __fish_set_separator -d "Check for Powerline font and set separator"
    # If Powerline modified fonts are installed, use them fir nicer output
    if type -q locate -a test -n (locate powerline)
        set -U SEPARATOR ''
    else
        set -U SEPARATOR ''
    end
end


# Colors
if not set -q __powerfish_colors_initialized
    set -U __powerfish_colors_initialized
    set -U fish_color_bg_normal 444
    set -U fish_text_light white
    set -U fish_text_dark black
    set -U vi_color_default red
    set -U vi_color_insert green
    set -U vi_color_replace $vi_color_insert
    set -U vi_color_visual magenta
    set -U git_color_untracked red
    set -U git_color_dirty yellow
    set -U git_color_clean green
    set -U fish_color_venv magenta
    set -U fish_color_user $fish_color_bg_normal
    set -U fish_color_root red
    set -U fish_color_remote yellow
    set -U fish_color_cwd blue
end


function __prompt_segment -d 'Draw prompt segment'
	set -l fg $argv[1]
	set -l bg $argv[2]
	if not set -q current_background
		set -g current_background $fish_color_bg_normal
	end
	echo -n -s (set_color $current_background -b $bg) $SEPARATOR (set_color $fg -b $bg)
	set current_background $bg
end

function fish_mode_prompt --description 'Displays the current mode'
  # Do nothing if not in vi mode
  if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case default
        set -g current_background $vi_color_default 
        set_color -b $vi_color_default
        echo ' N '
      case insert
        set -g current_background $vi_color_insert 
        set_color -b $vi_color_insert
        echo ' I '
      case replace-one
        set -g current_background $vi_color_replace 
        set_color -b $vi_color_replace
        echo ' R '
      case visual
        set -g current_background $vi_color_visual 
        set_color -b $vi_color_visual
        echo ' V '
    end
    # If we are in virtual environment, get a properly colored prompt
    if test -n "$VIRTUAL_ENV"
        echo (__prompt_segment $fish_text_light $fish_color_venv)
    # Otherwise color it according to user level
    else
        # TODO: Remove duplicate code
        switch $USER
        case root toor
            echo (__prompt_segment $fish_text_light $fish_color_root)
        case '*'
            echo (__prompt_segment $fish_text_light $fish_color_user)
        end
    end
  end
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
    set -g user_status_color
    set -g user_status_text $fish_text_light
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
    case sshd mosh-server
        echo (__prompt_segment $fish_text_dark $fish_color_remote)" at $__fish_prompt_hostname "
    case '*'
        echo ''
    end
end


function __cwd_prompt -d "Write out current working directory"
    echo (__prompt_segment $fish_text_dark $fish_color_cwd)" "(prompt_pwd)" "
end


function __git_prompt -d "Write out the git prompt"
    # Skip if git is not installed
    type -q git; or return 1

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
        set git_flags ''
        if test -n (__is_git_dirty)
            # Initialize counters
            set -l untracked 0
            set -l modified 0
            set -l staged 0
            set -l conflicted 0
            set -l stashed 0
            # Get all info about branch
            for i in (git status --porcelain | cut -c 1-2 | sort | uniq -c | string trim -l)
                # Third field is status flag
                switch (echo $i | string sub -s 3)
                    case "U?" "?U" "DD" "AA"
                        set conflicted (math $conflicted+(__count $i))
                    case "?M" "?D"
                        set modified (math $modified+(__count $i))
                    case '??'
                        set untracked (math $untracked+(__count $i))
                    case "*"
                        set staged (math $staged+(__count $i))
                end
            end
            # Get number of stashed files
            set stashed (math $stashed+(git stash list | wc -l))
             
            if test $untracked -gt 0
                set git_flags "$UNTRACKED $untracked " 
            end
            if test $modified -gt 0
                set git_flags "$git_flags$MODIFIED $modified " 
            end
            if test $staged -gt 0
                set git_flags "$git_flags$STAGED $staged " 
            end
            if test $conflicted -gt 0
                set git_flags "$git_flags$CONFLICTED $conflicted " 
            end
            if test $stashed -gt 0
                set git_flags "$git_flags$STASHED $stashed "
            end
        end
        __set_git_color
        echo -n -s (__prompt_segment $git_status_text $git_status_color)\
                   " $BRANCH "(__git_branch_name)" $git_flags"\
                   (__prompt_segment $git_status_color normal)
    else
        # Not in git repo, don't print anything, just set proper colors
        echo (__prompt_segment $fish_color_cwd normal)
    end
end

function fish_prompt --description 'Write out the prompt'
    # Set separator once at start
    if not set -q __fish_separator_set
        set -U __fish_separator_set
        __fish_set_separator
    end

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
