# alias ssh="kitty +kitten ssh"
alias 256col="TERM=xterm-256color"

abbr q 'exit'
abbr l 'ls -lh'
abbr ll 'ls -lah'

# thefuck
function fuck -d "Correct your previous console command"
  set -l fucked_up_command $history[1]
  env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
  if [ "$unfucked_command" != "" ]
    eval $unfucked_command
    builtin history delete --exact --case-sensitive -- $fucked_up_command
    builtin history merge ^ /dev/null
  end
end

# vterm
function vterm_printf;
  if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end
    printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
  else if string match -q -- "screen*" "$TERM"
    printf "\eP\e]%s\007\e\\" "$argv"
  else
    printf "\e]%s\e\\" "$argv"
  end
end

if [ "$INSIDE_EMACS" = 'vterm' ]
  function clear
    vterm_printf "51;Evterm-clear-scrollback";
    tput clear;
  end
end

function fish_title
  hostname
  echo ":"
  pwd
end

function vterm_prompt_end;
  vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
end
functions --copy fish_prompt vterm_old_fish_prompt
function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
  printf "%b" (string join "\n" (vterm_old_fish_prompt))
  vterm_prompt_end
end

function vterm_cmd --description 'Run an Emacs command among the ones been defined in vterm-eval-cmds.'
  set -l vterm_elisp ()
  for arg in $argv
    set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
  end
  vterm_printf '51;E'(string join '' $vterm_elisp)
end

function gg
  set -q argv[1]; or set argv[1] "."
  vterm_cmd magit-status (realpath "$argv")
end

function ff
  set -q argv[1]; or set argv[1] "."
  vterm_cmd find-file (realpath "$argv")
end

function find-file
  set -q argv[1]; or set argv[1] "."
  vterm_cmd find-file (realpath "$argv")
end

function magit-status
  set -q argv[1]; or set argv[1] "."
  vterm_cmd magit-status (realpath "$argv")
end

function magit-clone
  set -q argv[1]; or set argv[1] "."
  vterm_cmd magit-clone (realpath "$argv")
end

function cdp
  set -q argv[1]; or set argv[1] "."
  vterm_cmd project-find-file (realpath "$argv")
end

function project-find-file
  set -q argv[1]; or set argv[1] "."
  vterm_cmd project-find-file (realpath "$argv")
end

function say
  vterm_cmd message "%s" "$argv"
end