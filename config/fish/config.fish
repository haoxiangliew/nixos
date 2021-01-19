set -x PATH $PATH ~/.emacs.d/bin

set -gx MOZ_X11_EGL  1

if status is-interactive
and not set -q TMUX
    exec tmux new-session -A -s main
end
