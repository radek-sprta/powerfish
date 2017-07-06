# Characters
if not set --query __powerfish_characters_initialized
    set --universal __powerfish_characters_initialized
    set --universal AHEAD '⬆'
    set --universal BEHIND '⬇'
    set --universal BRANCH ''
    set --universal CONFLICTED '✖'
    set --universal DETACHED '➦'
    set --universal FAILED '✘'
    set --universal JOBS '⚙'
    set --universal MODIFIED '✚'
    set --universal STAGED '●'
    set --universal STASHED '⚑'
    set --universal UNTRACKED '…'
end

function __fish_set_separator -d "Check for Powerline font and set separator"
    # If Powerline modified fonts are installed, use them for nicer output
    if type --quiet locate; and test -n (locate powerline)
        set --universal SEPARATOR ''
    else
        set --universal SEPARATOR ''
    end
end


# Colors
if not set --query __powerfish_colors_initialized
    set --universal __powerfish_colors_initialized
    set --universal fish_color_bg_normal 444
    set --universal fish_color_cwd blue
    set --universal fish_color_failed red
    set --universal fish_color_git_clean green
    set --universal fish_color_git_dirty yellow
    set --universal fish_color_git_untracked red
    set --universal fish_color_root red
    set --universal fish_color_remote yellow
    set --universal fish_color_user $fish_color_bg_normal
    set --universal fish_color_venv magenta
    set --universal fish_color_vi_default red
    set --universal fish_color_vi_insert green
    set --universal fish_color_vi_replace $fish_color_vi_insert
    set --universal fish_color_vi_visual magenta
    set --universal fish_text_light white
    set --universal fish_text_dark black
end


function __prompt_separator -d 'Draw prompt segment'
    # Argv[1]: Foreground color.
    # Argv[2]: Background color.

	set --local fg $argv[1]
	set --local bg $argv[2]
	printf "%s%s%s" (set_color $current_background --background $bg)\
                    $SEPARATOR (set_color $fg --background $bg)
	set current_background $bg
end


function __prompt_start -d 'Start the prompt'
    # Argv[1]: Head of prompt.
    # Argv[2]: Background color.

    # Do nothing if prompt has already started
    if not set --query prompt_head
        set --global prompt_head $argv[1]
        set --global current_background $argv[2]
    end
end


function __prompt_end -d 'End the prompt'
        printf "%s " (__prompt_separator normal normal)
        set -e prompt_head
end


function fish_mode_prompt --description 'Displays the current mode'
    # Do nothing if not in vi mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        # Start the prompt, since vi mode always comes first
        __prompt_start "vi" normal

        switch $fish_bind_mode
          case default
            set --global current_background $fish_color_vi_default
            set_color --background $fish_color_vi_default
            printf " %s " 'N'
          case insert
            set --global current_background $fish_color_vi_insert
            set_color --background $fish_color_vi_insert
            printf " %s " 'I'
          case replace-one
            set --global current_background $fish_color_vi_replace
            set_color --background $fish_color_vi_replace
            printf " %s " 'R'
          case visual
            set --global current_background $fish_color_vi_visual
            set_color --background $fish_color_vi_visual
            printf " %s " 'V'
        end
    end
end


function __venv_prompt -d "Write out virtual environment prompt"
    # Do nothing if not in virtual environment
    if test -n "$VIRTUAL_ENV"
        # Start the prompt if necessary, otherwise just draw separator
        if not set --query prompt_head
            __prompt_start "venv" $fish_color_venv
        else
            printf "%s" (__prompt_separator $fish_text_light $fish_color_venv)
        end

        set_color $fish_text_light --background $fish_color_venv
        printf " %s " (basename $VIRTUAL_ENV)
    end
end


function __user_prompt -d "Write out the user prompt"

    # Status of last command
    function __fish_prompt_status -d "Show if the last command failed"
        if test $last_status -ne 0
            set_color $fish_color_failed --background $user_status_color
            printf "%s " $FAILED
        end
    end

    function __fish_prompt_jobs -d "Show the number of background jobs"
        set -l bg_jobs (jobs | wc --lines)
        if test "$bg_jobs" -gt 0
            set_color $user_status_text --background $user_status_color
            printf "%s %s " $JOBS $bg_jobs
        end
    end

    # Use different colors for normal user and root
    set --global user_status_color
    set --global user_status_text $fish_text_light
	switch $USER
	case root toor
        set user_status_color $fish_color_root
    case '*'
        set user_status_color $fish_color_user
    end

    # Start the prompt if necessary, otherwise just draw separator
    if not set --query prompt_head
        __prompt_start "user" $user_status_color
    else
        echo (__prompt_separator $user_status_text $user_status_color)
    end

    set_color --background $user_status_color
    printf " %s%s%s%s " (__fish_prompt_status) (__fish_prompt_jobs)\
                        (set_color $user_status_text) $USER
end


function __hostname_prompt -d "Write out the hostname prompt"

    # Hostname, calculate just once
	if not set --query __fish_prompt_hostname
		set --global __fish_prompt_hostname (hostname | string split .)[1]
	end

    # Only show remote hosts
    set --local ppid (ps --format ppid= --pid %self | string trim)
    switch (ps --format comm= --pid $ppid)
    case sshd mosh-server
        printf "%s at %s "\
            (__prompt_separator $fish_text_dark $fish_color_remote)\
            $__fish_prompt_hostname
    end
end


function __cwd_prompt -d "Write out current working directory"
    printf "%s %s " (__prompt_separator $fish_text_dark $fish_color_cwd)\
                    (prompt_pwd)
end


function __git_prompt -d "Write out the git prompt"
    # Skip if git is not installed
    type --quiet git; or return 1

    function __git_branch_name -d 'Get branch name'
        # Not on a branch
        if string match --regex 'no branch' $git_status >/dev/null
            printf "%s %s " $DETACHED (__get_tag_or_hash)
        # Initial commit
        else if set branch_name (string match --regex 'commit on (.*)' $git_status)
            printf "%s %s " $BRANCH $branch_name[2]
        # Otherwise get a branch name normally
        else
            printf "%s %s " $BRANCH (string match --regex '## ([^.]*)' $git_status)[2]
        end
    end

    function __get_tag_or_hash -d 'Get tag or hash'
        if set --local tag (git describe --tags --exact-match ^/dev/null)
            printf "%s" $tag
        else
            # Tag does not match, print a hash
            printf "%s" (git rev-parse --short HEAD)
        end
    end

    function __set_git_color -d 'Set color depending on the tree status'
        # If there are more lines than just the branch line, repo is dirty
        if test (count $git_status) -gt 1
            # Check if there are untracked files
            if string match --regex '\?\? ' $git_status >/dev/null ^/dev/null
                set --global git_status_color $fish_color_git_untracked
                set --global git_status_text $fish_text_light
            else
                set --global git_status_color $fish_color_git_dirty
                set --global git_status_text $fish_text_dark
            end
        else
            set --global git_status_color $fish_color_git_clean
            set --global git_status_text $fish_text_dark
        end
    end

    function __get_divergence -d 'Get divergence between local and remote'
        set --local branch_info $git_status[1]
        set --local branch_ahead (string match --regex '\[ahead (\d*)' $branch_info)
        set --local branch_behind (string match --regex 'behind (\d*)\]' $branch_info)
        # Check how much we are ahead
        if test (count $branch_ahead) -eq 2; and test $branch_ahead[2] -gt 0
            set ahead "$AHEAD $branch_ahead[2]"
        end
        # Check how much we are behind
        if test (count $branch_behind) -eq 2; and test $branch_behind[2] -gt 0
            set behind "$BEHIND $branch_behind[2]"
        end
        if test -n "$ahead" -a -n "$behind"
            printf "%s%s " "$ahead" "$behind"
        else if test -n "$ahead"
            printf "%s " "$ahead"
        else if test -n "$behind"
            printf "%s " "$behind"
        end
    end

    function __get_git_flags -d 'Get the working tree flags'
        # Initialize counters
        set --local untracked 0
        set --local modified 0
        set --local staged 0
        set --local conflicted 0
        # Get all info about branch
        for i in $git_status
            # First two characters show the status
            switch (echo $i | string sub --length 2)
                case "U?" "?U" "DD" "AA"
                    set conflicted (math $conflicted+1)
                case "?M" "?D"
                    set modified (math $modified+1)
                case "\?\?"
                    set untracked (math $untracked+1)
                case "##"
                    # Branch name; do nothing
                case "*"
                    set staged (math $staged+1)
            end
        end
        # Get number of stashed files
        set stashed (git stash list | wc --lines)

        if test $untracked -gt 0
            set git_flags "$UNTRACKED $untracked"
        end
        if test $modified -gt 0
            set git_flags "$git_flags$MODIFIED $modified"
        end
        if test $staged -gt 0
            set git_flags "$git_flags$STAGED $staged"
        end
        if test $conflicted -gt 0
            set git_flags "$git_flags$CONFLICTED $conflicted"
        end
        if test $stashed -gt 0
            set git_flags "$git_flags$STASHED $stashed"
        end
        if set --query git_flags
            printf "%s " $git_flags
        end
    end

    # Get git repo status
    if set --global git_status (git status --porcelain --branch --ignore-submodules=dirty ^/dev/null)
        __set_git_color
        printf "%s %s%s%s" (__prompt_separator $git_status_text $git_status_color) \
                           (__git_branch_name) (__get_divergence) (__get_git_flags)
    end
end


function fish_prompt --description 'Write out the prompt'
    # Save the last status
    set --global last_status $status

    # Set separator once at start
    if not set --query __fish_separator_set
        set --universal __fish_separator_set
        __fish_set_separator
    end

    # Disable virtual environment prompt; we have our own override
    set --universal VIRTUAL_ENV_DISABLE_PROMPT 1

	printf "%s%s%s%s%s%s" \
        (__venv_prompt)\
        (__user_prompt)\
        (__hostname_prompt)\
        (__cwd_prompt)\
        (__git_prompt)\
        (__prompt_end)
end
