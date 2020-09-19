# name: Powerfish
# description: Powerfish is an elegant and informative prompt for Fish.
# author: Radek Sprta
#
# Configuration:
# You can override some default options in ~/.config/fish/config.fish
#
#   # Hide default username
#   set -g DEFAULT_USER username
#
#   # Don't show counters for git flags etc.
#   set -g pf_no_counters true
#
#   # Change the color theme
#   set -g pf_color_theme default|tomorrow-night|solarized-dark

# Characters
function __pf_set_separator -d "Check for Powerline font and set separator"
    # If Powerline modified fonts are installed, use them for nicer output
    if type --quiet locate -a test -n (locate powerline)
        set --universal SEPARATOR ''
    else
        set --universal SEPARATOR ''
    end
end


if not set --query __pf_characters_initialized
    set --universal __pf_characters_initialized
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
    __pf_set_separator
end


# Colors
function __pf_set_color_theme -d 'Set color theme'
    # Argv[1]: Name of color theme to set

    switch "$argv[1]"
        case tomorrow-night
            __pf_colors_tomorrow
        case solarized-dark
            __pf_colors_solarized
        case solarized-light
            __pf_colors_solarized_light
        case "*"
            __pf_colors_default
    end
end


function __pf_colors_default -d 'Set default color theme'
    set --universal pf_current_theme 'default'

    set --universal pf_color_bg_normal 444
    set --universal pf_text_light white
    set --universal pf_text_dark black

    set --universal pf_color_cwd blue
    set --universal pf_color_failed red
    set --universal pf_color_jobs $pf_text_light
    set --universal pf_color_root red
    set --universal pf_color_remote yellow
    set --universal pf_color_user $pf_color_bg_normal
    set --universal pf_color_venv magenta

    set --universal pf_color_git_clean green
    set --universal pf_color_git_conflicted red
    set --universal pf_color_git_dirty yellow

    set --universal pf_color_vi_default red
    set --universal pf_color_vi_insert green
    set --universal pf_color_vi_replace $pf_color_vi_insert
    set --universal pf_color_vi_visual magenta
end


function __pf_colors_tomorrow -d 'Set Tommorrow Night color theme'
    set --universal pf_current_theme 'tomorrow-night'

    set --universal pf_color_bg_normal 282a2e
    set --universal pf_text_light 1d1f21
    set --universal pf_text_dark 1d1f21

    set --universal pf_color_cwd 81a2be
    set --universal pf_color_failed cc6666
    set --universal pf_color_jobs c5c8c6
    set --universal pf_color_root cc6666
    set --universal pf_color_remote f0c674
    set --universal pf_color_user $pf_color_bg_normal
    set --universal pf_color_venv b294bb

    set --universal pf_color_git_clean b5bd68
    set --universal pf_color_git_conflicted cc6666
    set --universal pf_color_git_dirty f0c674

    set --universal pf_color_vi_default de935f
    set --universal pf_color_vi_insert b5bd68
    set --universal pf_color_vi_replace b5bd68
    set --universal pf_color_vi_visual b294bb
end


function __pf_colors_solarized -d 'Set Solarized Dark color theme'
    set --universal pf_current_theme 'solarized-dark'

    set --universal pf_color_bg_normal 073642
    set --universal pf_text_light 002b36
    set --universal pf_text_dark 002b36

    set --universal pf_color_cwd 6c71c4
    set --universal pf_color_failed dc322f
    set --universal pf_color_jobs 657b83
    set --universal pf_color_root dc322f
    set --universal pf_color_remote b58900
    set --universal pf_color_user $pf_color_bg_normal
    set --universal pf_color_venv d33682

    set --universal pf_color_git_clean 859900
    set --universal pf_color_git_conflicted dc322f
    set --universal pf_color_git_dirty b58900

    set --universal pf_color_vi_default cb4b16
    set --universal pf_color_vi_insert 859900
    set --universal pf_color_vi_replace 2aa198
    set --universal pf_color_vi_visual d33682
end

function __pf_colors_solarized_light -d 'Set Solarized Light color theme'
    set --universal pf_current_theme 'solarized-light'

    set --universal pf_color_bg_normal eee8d5
    set --universal pf_text_light 586e75
    set --universal pf_text_dark 586e75

    set --universal pf_color_cwd 6c71c4
    set --universal pf_color_failed dc322f
    set --universal pf_color_jobs 657b83
    set --universal pf_color_root dc322f
    set --universal pf_color_remote b58900
    set --universal pf_color_user $pf_color_bg_normal
    set --universal pf_color_venv d33682

    set --universal pf_color_git_clean 859900
    set --universal pf_color_git_conflicted dc322f
    set --universal pf_color_git_dirty b58900

    set --universal pf_color_vi_default cb4b16
    set --universal pf_color_vi_insert 859900
    set --universal pf_color_vi_replace 2aa198
    set --universal pf_color_vi_visual d33682
end


# Prompt builders
function __pf_prompt_segment -d 'Draw prompt segment'
    # Argv[1]: Head of prompt.
    # Argv[2]: Foreground color.
    # Argv[3]: Background color.

    set --local head $argv[1]
	set --local fg $argv[2]
	set --local bg $argv[3]


    # Start the prompt if necessary, otherwise just draw separator
    if not set --query pf_prompt_head
        set --global pf_prompt_head $head
        set_color $fg --background $bg
    else
        printf "%s%s%s" (set_color $pf_current_background --background $bg)\
            $SEPARATOR (set_color $fg --background $bg)
    end

    set --global pf_current_background $bg
end


function __pf_prompt_end -d 'End the prompt'
        printf "%s " (__pf_prompt_segment "" normal normal)
        set --erase pf_prompt_head
end


function __pf_remove_count -d 'Remove count'
    printf "%s" (string replace --all --regex ' [0-9]' '' $argv[1])
end


function fish_mode_prompt --description 'Displays the current mode'
    # Do nothing if not in vi mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        switch $fish_bind_mode
          case default
            __pf_prompt_segment "vi" $pf_text_light $pf_color_vi_default
            printf " %s " 'N'
          case insert
            __pf_prompt_segment "vi" $pf_text_light $pf_color_vi_insert
            printf " %s " 'I'
          case replace-one
            __pf_prompt_segment "vi" $pf_text_light $pf_color_vi_replace
            printf " %s " 'R'
          case visual
            __pf_prompt_segment "vi" $pf_text_light $pf_color_vi_visual
            printf " %s " 'V'
        end
    end
end


function __pf_status_prompt -d "Show status of last command and background jobs"

    function __pf_command_status -d "Show if the last command failed"
        if test "$pf_last_status" -ne 0
            set_color $pf_color_failed
            printf "%s " $FAILED
        end
    end

    function __pf_jobs_status -d "Show the number of background jobs"
        set --local bg_jobs (jobs | wc -l)
        if test "$bg_jobs" -gt 0
            set_color $pf_color_jobs
            printf "%s %s " $JOBS $bg_jobs
        end
    end

    set --local command_status (__pf_command_status)
    set --local jobs_status (__pf_jobs_status)

    # If there is nothing to show, dont draw the prompt
    if test -n "$command_status" -o -n "$jobs_status"

        __pf_prompt_segment "status" $pf_text_light $pf_color_user
        if set --query pf_no_counters
            printf " %s%s" $command_status (__pf_remove_count $jobs_status)
        else
            printf " %s%s" $command_status $jobs_status
        end
    end
end


function __pf_venv_prompt -d "Write out virtual environment prompt"
    # Do nothing if not in virtual environment
    if test -n "$VIRTUAL_ENV"
        __pf_prompt_segment "venv" $pf_text_light $pf_color_venv
        printf " %s " (basename $VIRTUAL_ENV)
    end
end


function __pf_user_prompt -d "Write out the user prompt"

    # If we are under default user, do nothing
    if test "$USER" != "$DEFAULT_USER"

        # Use different colors for normal user and root
        set --global pf_user_status_bg
        set --global pf_user_status_text $pf_text_light
        if test (id -u "$USER") -eq 0
            set pf_user_status_bg $pf_color_root
        else
            set pf_user_status_bg $pf_color_user
        end

        __pf_prompt_segment "user" $pf_user_status_text $pf_user_status_bg
        printf " %s " $USER
    end
end


function __pf_hostname_prompt -d "Write out the hostname prompt"

    # Hostname, calculate just once
	if not set --query __pf_prompt_hostname
		set --global __pf_prompt_hostname (hostname | string split .)[1]
	end

    # Only show remote hosts
    if set --local ppid (ps -o ppid= -p %self | string trim)
        switch (ps -o comm= -p $ppid)
        case sshd mosh-server
            __pf_prompt_segment "host" $pf_text_dark $pf_color_remote
            printf " at %s " $__pf_prompt_hostname
        end
    end
end


function __pf_cwd_prompt -d "Write out current working directory"
    __pf_prompt_segment "cwd" $pf_text_dark $pf_color_cwd
    printf " %s " (prompt_pwd)
end


function __pf_git_prompt -d "Write out the git prompt"
    # Skip if git is not installed
    type --quiet git; or return 1

    function __pf_git_branch_name -d 'Get branch name'
        # Not on a branch
        if string match --regex 'no branch' "$pf_git_status" >/dev/null
            printf "%s %s " $DETACHED (__pf_git_tag_or_hash)
        # Initial commit
        else if set branch_name (string match --regex 'commit(s yet)? on (.*)' "$pf_git_status")
            printf "%s %s " $BRANCH $branch_name[3]
        # Otherwise get a branch name normally
        else
            printf "%s %s " $BRANCH (string match --regex '## (.+)\.\.\.' "$pf_git_status")[2]
        end
    end

    function __pf_git_tag_or_hash -d 'Get tag or hash'
        if set --local tag (git describe --tags --exact-match 2>/dev/null)
            printf "%s" $tag
        else
            # Tag does not match, print a hash
            printf "%s" (git rev-parse --short HEAD)
        end
    end

    function __pf_git_set_color -d 'Set color depending on the tree status'
        # If there are more lines than just the branch line, repo is dirty
        if test (count $pf_git_status) -gt 1
            if string match --regex 'U\? |\?U |DD |AA ' "$pf_git_status" >/dev/null
                set --global pf_git_status_bg $pf_color_git_conflicted
                set --global pf_git_status_text $pf_text_light
            else
                set --global pf_git_status_bg $pf_color_git_dirty
                set --global pf_git_status_text $pf_text_dark
            end
        else
            set --global pf_git_status_bg $pf_color_git_clean
            set --global pf_git_status_text $pf_text_dark
        end
    end

    function __pf_git_divergence -d 'Get divergence between local and remote'
        set --local branch_info "$pf_git_status[1]"
        set --local branch_ahead (string match --regex '\[ahead (\d*)' "$branch_info")
        set --local branch_behind (string match --regex 'behind (\d*)\]' "$branch_info")
        # Check how much we are ahead
        if test (count $branch_ahead) -eq 2; and test "$branch_ahead[2]" -gt 0
            set ahead "$AHEAD $branch_ahead[2]"
        end
        # Check how much we are behind
        if test (count $branch_behind) -eq 2; and test "$branch_behind[2]" -gt 0
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

    function __pf_git_flags -d 'Get the working tree flags'
        # Initialize counters
        set --local untracked 0
        set --local modified 0
        set --local staged 0
        set --local conflicted 0
        # Get all info about branch
        for i in $pf_git_status
            # First two characters show the status
            switch (echo "$i" | string sub --length 2)
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
        set stashed (git stash list | wc -l)

        if test "$untracked" -gt 0
            set git_flags "$UNTRACKED $untracked "
        end
        if test "$modified" -gt 0
            set git_flags "$git_flags$MODIFIED $modified "
        end
        if test "$staged" -gt 0
            set git_flags "$git_flags$STAGED $staged "
        end
        if test "$conflicted" -gt 0
            set git_flags "$git_flags$CONFLICTED $conflicted "
        end
        if test "$stashed" -gt 0
            set git_flags "$git_flags$STASHED $stashed "
        end
        if set --query git_flags
            printf "%s" $git_flags
        end
    end

    # Get git repo status
    if set --global pf_git_status (git status --porcelain --branch --ignore-submodules=dirty 2>/dev/null)
        __pf_git_set_color
        __pf_prompt_segment "git" $pf_git_status_text $pf_git_status_bg
        if set --query pf_no_counters
            printf " %s%s%s" (__pf_git_branch_name)\
                (__pf_remove_count (__pf_git_divergence))\
                (__pf_remove_count (__pf_git_flags))
        else
            printf " %s%s%s" (__pf_git_branch_name) (__pf_git_divergence) (__pf_git_flags)
        end
    end
end


function fish_prompt --description 'Write out the prompt'
    # Save the last status
    set --global pf_last_status $status

    # Set color theme
    if not set --query pf_current_theme; or set --query pf_color_theme
        # If user set theme is the same as current theme, do nothing
        if test -z "$pf_current_theme" -o "$pf_current_theme" != "$pf_color_theme"
            __pf_set_color_theme "$pf_color_theme"
        end
    end

    # Disable virtual environment prompt; we have our own override
    set --universal VIRTUAL_ENV_DISABLE_PROMPT 1

	printf "%s%s%s%s%s%s" \
        (__pf_status_prompt)\
        (__pf_venv_prompt)\
        (__pf_user_prompt)\
        (__pf_hostname_prompt)\
        (__pf_cwd_prompt)\
        (__pf_git_prompt)\
        (__pf_prompt_end)
end
