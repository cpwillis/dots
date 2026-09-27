#!/usr/bin/env bash
# runs repo_download.sh, install.sh and update_configs.sh against a throwaway home with brew, sudo, defaults etc stubbed
# macOS only, needs network (clones omz-git-branch); usage: tests/sandbox.sh [repo]
set -uo pipefail
REPO=$(cd "${1:-$(dirname "$0")/..}" && pwd)
T=$(mktemp -d "${TMPDIR:-/tmp}/dots-sandbox.XXXXXX"); mkdir -p "$T/bin" "$T/state" "$T/home"
TH="$T/home"; LOG="$T/calls.txt"; : > "$LOG"
REAL_GIT=$(command -v git)
export LOG REPO REAL_GIT STATE="$T/state"

# ── shims ──
for c in sudo open osascript defaults killall chsh softwareupdate curl; do
    printf '#!/bin/bash\necho "%s $*" >> "$LOG"\n' "$c" > "$T/bin/$c"
done
cat > "$T/bin/sleep" <<'EOF'
#!/bin/bash
[[ $1 == 60 && -f $STATE/slow_keepalive ]] && exec /bin/sleep 5
exec /bin/sleep 0.1
EOF
cat > "$T/bin/brew" <<'EOF'
#!/bin/bash
echo "brew $*" >> "$LOG"
if [[ "$1 $2" == "bundle dump" ]]; then
    for a; do [[ $a == --file=* ]] && cp "$REPO/config/Brewfile" "${a#--file=}"; done
elif [[ "$1" == bundle ]]; then
    { stat -Lf %i /dev/fd/9 > "$STATE/bundle_stdout"; } 9>&1
    [[ -f $STATE/eat_stdin ]] && cat > /dev/null
    [[ -f $STATE/fail_bundle ]] && exit 1
    if [[ -f $STATE/partial_bundle ]]; then
        printf '\033[31mInstalling logisim-evolution has failed!\033[0m\nInstalling Affinity Designer 2 has failed!\n' >&2
        exit 1
    fi
    [[ -f $STATE/slow_bundle ]] && /bin/sleep 5
fi
exit 0
EOF
cat > "$T/bin/xcode-select" <<'EOF'
#!/bin/bash
echo "xcode-select $*" >> "$LOG"
case $1 in
    -p) [[ -f $STATE/clt ]] && exit 0; [[ -f $STATE/pending ]] && mv "$STATE/pending" "$STATE/clt"; exit 2 ;;
    --install) touch "$STATE/pending" ;;
esac
EOF
cat > "$T/bin/git" <<'EOF'
#!/bin/bash
if [[ $1 == clone ]]; then echo "git $* [GIT_CONFIG_GLOBAL=${GIT_CONFIG_GLOBAL:-unset}]" >> "$LOG"; fi
if [[ $1 == clone && $2 == https://github.com/cpwillis/dots.git ]]; then
    mkdir -p "$(dirname "$3")" && cp -R "$REPO" "$3" && sed -i '' '/activateSettings/d' "$3/meta/macOS_settings.sh"
    exit
fi
exec "$REAL_GIT" "$@"
EOF
cat > "$T/bin/gh" <<'EOF'
#!/bin/bash
echo "gh $*" >> "$LOG"
[[ "$1 $2" == "auth login" ]] && mkdir -p "$HOME/.ssh" && touch "$HOME/.ssh/id_ed25519"
exit 0
EOF
chmod +x "$T/bin/"*

# fake existing gitconfig with the https->ssh rewrite; ssh always fails
printf '[url "git@github.com:"]\n\tinsteadOf = "https://github.com/"\n' > "$TH/.gitconfig"

# sbx <home> cmd...: run with shims, a throwaway home and no inherited env
sbx() { local h=$1; shift; env -i PATH="$T/bin:/usr/bin:/bin:/usr/sbin:/sbin" HOME="$h" SHELL=/bin/bash \
    TERM=xterm-256color LOG="$LOG" REPO="$REPO" REAL_GIT="$REAL_GIT" STATE="$T/state" GIT_SSH_COMMAND=false "$@"; }
PASSED=0; FAILED=0
check() { local n=$1; shift; if "$@"; then echo "PASS  $n"; PASSED=$((PASSED+1)); else echo "FAIL  $n"; FAILED=$((FAILED+1)); fi; }
calls() { grep -v '^sudo -n true' "$LOG"; }
no_call() { ! grep -q "^$1" "$LOG"; }
state() { cat "$1/.local/state/dots/install-done" 2>/dev/null | paste -sd' ' -; }
headers() { sed 's/\x1b\[[0-9;]*m//g' "$T/$1.out" | grep -c '^\['; }
ALL="homebrew packages omz macos dotfiles ssh shell update"
install() { local h=$1 answers=$2 out=$3; shift 3; : > "$LOG"
    printf "$answers" | sbx "$h" "$REPO/scripts/install.sh" "$@" > "$T/$out.out" 2>&1; }

# ── A: repo_download on a Mac with no CLT, via the README one-liner form ──
echo "== A: repo_download.sh, fresh (no CLT, existing ~/.gitconfig rewrite)"
printf 'y\ny\nn\n' | sbx "$TH" bash -c "$(cat "$REPO/scripts/repo_download.sh")" > "$T/a.out" 2>&1; rc=$?
check "exit 0" test $rc -eq 0
check "CLT install requested" grep -q '^xcode-select --install' "$LOG"
check "waited for CLT (polled >= 3)" test "$(grep -c '^xcode-select -p' "$LOG")" -ge 3
check "dots clone skips global config" grep -q 'dots.git.*GIT_CONFIG_GLOBAL=/dev/null' "$LOG"
check "plugin clone skips global config" grep -q 'omz-git-branch.git.*GIT_CONFIG_GLOBAL=/dev/null' "$LOG"
P="$TH/.oh-my-zsh/custom/plugins/omz-git-branch"
check "plugin cloned over https" test "$("$REAL_GIT" -C "$P" config --get remote.origin.url 2>/dev/null)" = https://github.com/cpwillis/omz-git-branch.git
bad=0
while IFS=, read -r n r s; do
    n=${n//\"/}; r=${r//\"/}; s=${s//\"/}; d=${s/\$HOME/$TH}
    cmp -s "$REPO/$r" "$d" || { echo "      mismatch: $n -> $d"; bad=1; }
done < <(tail -n +2 "$REPO/meta/manifest.csv")
check "all manifest files deployed" test $bad -eq 0
check "brew bundle ran" grep -q '^brew bundle --file=' "$LOG"
check "brew bundle stdout is the terminal, not a pipe" test "$(cat "$T/state/bundle_stdout")" = "$(stat -f %i "$T/a.out")"
check "defaults writes applied" grep -q '^defaults write' "$LOG"
check "gh login generates ssh key" grep -q '^gh auth login --hostname github.com --git-protocol ssh --web' "$LOG"
check "chsh ran (SHELL=/bin/bash)" grep -q '^chsh -s /bin/zsh' "$LOG"
check "softwareupdate skipped on n" no_call softwareupdate
check "all steps recorded" test "$(state "$TH")" = "$ALL"
check "finished" grep -q 'All done!' "$T/a.out"
echo "      stubbed sudo calls: $(grep '^sudo rm' "$LOG" | sed 's/^sudo //' | paste -sd, - || true)"

# ── B: rerun with the clone present, every step already done ──
echo "== B: repo_download.sh, rerun"
: > "$LOG"
printf 'y\ny\n' | sbx "$TH" bash -c "$(cat "$REPO/scripts/repo_download.sh")" > "$T/b.out" 2>&1; rc=$?
check "exit 0" test $rc -eq 0
check "removed existing clone" grep -q 'Removed existing directory' "$T/b.out"
check "no CLT install" no_call 'xcode-select --install'
check "nothing to run" grep -q 'Nothing to run, every step is done' "$T/b.out"
check "no brew or gh calls" bash -c "! grep -q '^brew \|^gh ' '$LOG'"

# ── B2: --fresh reruns every step, and each is idempotent ──
echo "== B2: install.sh --fresh"
install "$TH" 'y\ny\nn\n' b2 --fresh; rc=$?
check "exit 0" test $rc -eq 0
check "brew bundle ran again" grep -q '^brew bundle --file=' "$LOG"
check "plugin already installed" grep -q 'omz-git-branch already installed' "$T/b2.out"
check "ssh key already exists" grep -q 'Already exists' "$T/b2.out"
check "gh not called" no_call gh
check "all steps recorded once" test "$(state "$TH")" = "$ALL"

# ── C: dry run changes nothing ──
echo "== C: install.sh --dry-run"
TH2="$T/home2"; mkdir -p "$TH2"
install "$TH2" 'y\ny\nn\n' c --dry-run; rc=$?
check "exit 0" test $rc -eq 0
check "only open -a App Store executed" test "$(calls)" = "open -a App Store"
check "home untouched (no state file)" test -z "$(ls -A "$TH2")"
check "plugin clone printed" grep -q '~ env GIT_CONFIG_GLOBAL=/dev/null git clone' "$T/c.out"
check "gh login printed" grep -q '~ gh auth login --hostname github.com --git-protocol ssh --web' "$T/c.out"

# ── G: skip, resume, only, failure, Ctrl+C, bad input ──
echo "== G: --skip then plain rerun"
TH3="$T/home3"; mkdir -p "$TH3"
install "$TH3" 'y\ny\n' g1 --skip ssh,update; rc=$?
check "skip: exit 0" test $rc -eq 0
check "skip: gh not called" no_call gh
check "skip: update prompt not shown" bash -c "! grep -q 'Install macOS updates' '$T/g1.out'"
check "skip: skipped steps not recorded" test "$(state "$TH3")" = "homebrew packages omz macos dotfiles shell"
check "skip: says what's left" grep -q 'Still to do: ssh update' "$T/g1.out"
install "$TH3" 'y\nn\n' g2; rc=$?
check "resume: exit 0" test $rc -eq 0
check "resume: says what was done" grep -q 'Resuming, already done: homebrew packages omz macos dotfiles shell' "$T/g2.out"
check "resume: only the 2 skipped steps ran" test "$(headers g2)" -eq 2
check "resume: gh called" grep -q '^gh auth login' "$LOG"
check "resume: brew not called" no_call brew
check "resume: all steps recorded" test "$(tr ' ' '\n' <<< "$(state "$TH3")" | sort | paste -sd' ' -)" = "$(tr ' ' '\n' <<< "$ALL" | sort | paste -sd' ' -)"
check "resume: finished" grep -q 'All done!' "$T/g2.out"

echo "== G: --only on a finished install"
install "$TH3" 'y\n' g3 --only dotfiles; rc=$?
check "only: exit 0" test $rc -eq 0
check "only: dotfiles ran" grep -q 'Deploying dotfiles' "$T/g3.out"
check "only: nothing else ran" test "$(headers g3)" -eq 1
check "only: no duplicate state lines" test "$(wc -l < "$TH3/.local/state/dots/install-done")" -eq 8

echo "== G: failure then resume"
TH4="$T/home4"; mkdir -p "$TH4"; touch "$T/state/fail_bundle"
install "$TH4" 'y\ny\n' g4; rc=$?
/bin/rm -f "$T/state/fail_bundle"
check "fail: exit 1" test $rc -eq 1
check "fail: names the step" grep -q 'Failed during the packages step' "$T/g4.out"
check "fail: only earlier steps recorded" test "$(state "$TH4")" = "homebrew"
install "$TH4" 'y\ny\nn\n' g5; rc=$?
check "fail resume: exit 0" test $rc -eq 0
check "fail resume: homebrew not rerun" no_call 'brew update'
check "fail resume: packages ran" grep -q '^brew bundle --file=' "$LOG"
check "fail resume: all steps recorded" test "$(state "$TH4")" = "$ALL"

echo "== G: Ctrl+C then resume"
TH5="$T/home5"; mkdir -p "$TH5"; touch "$T/state/slow_bundle"; : > "$LOG"
sbx "$TH5" /usr/bin/python3 -c '
import os, signal, subprocess, sys, time
with open(sys.argv[2], "w") as out:
    p = subprocess.Popen([sys.argv[1]], stdin=subprocess.PIPE, stdout=out, stderr=subprocess.STDOUT, start_new_session=True)
    p.stdin.write(b"y\ny\n"); p.stdin.flush()
    for _ in range(100):
        if "brew bundle" in open(os.environ["LOG"]).read(): break
        time.sleep(0.1)
    os.killpg(p.pid, signal.SIGINT)
    sys.exit(p.wait() & 0xff)
' "$REPO/scripts/install.sh" "$T/g6.out"; rc=$?
/bin/rm -f "$T/state/slow_bundle"
check "int: exit 130" test $rc -eq 130
check "int: names the step" grep -q 'Interrupted during the packages step' "$T/g6.out"
check "int: interrupted step not recorded" test "$(state "$TH5")" = "homebrew"
install "$TH5" 'y\ny\nn\n' g7; rc=$?
check "int resume: exit 0" test $rc -eq 0
check "int resume: starts at packages" grep -q 'Resuming, already done: homebrew\.' "$T/g7.out"
check "int resume: all steps recorded" test "$(state "$TH5")" = "$ALL"

echo "== G: bad input"
install "$TH5" '' g8 --skip sshh; rc=$?
check "unknown step: exit 1" test $rc -eq 1
check "unknown step: named" grep -q 'unknown step: sshh' "$T/g8.out"
install "$TH5" '' g9 --only; rc=$?
check "--only without list: fails" test $rc -ne 0
check "bad input: no state change" test "$(state "$TH5")" = "$ALL"

echo "== H: brew bundle item failures are skipped and reported"
TH6="$T/home6"; mkdir -p "$TH6"; touch "$T/state/partial_bundle"
install "$TH6" 'y\ny\nn\n' h1; rc=$?
/bin/rm -f "$T/state/partial_bundle"
FF="$TH6/.local/state/dots/packages-failed"
check "partial: exit 0" test $rc -eq 0
check "partial: warns in the step" grep -q 'Skipped, could not install: logisim-evolution, Affinity Designer 2' "$T/h1.out"
check "partial: install carried on" grep -q 'Deploying dotfiles' "$T/h1.out"
check "partial: notice at the end" grep -q 'Not installed by brew bundle: logisim-evolution, Affinity Designer 2\.' "$T/h1.out"
check "partial: failures recorded" test "$(paste -sd'|' "$FF")" = "logisim-evolution|Affinity Designer 2"
check "partial: all steps recorded" test "$(state "$TH6")" = "$ALL"
install "$TH6" 'y\ny\n' h2 --only packages; rc=$?
check "retry ok: exit 0" test $rc -eq 0
check "retry ok: failure record cleared" test ! -e "$FF"
check "retry ok: no notice" bash -c "! grep -q 'Not installed by brew bundle' '$T/h2.out'"

echo "== H: brew bundle can't eat answers meant for later prompts"
TH7="$T/home7"; mkdir -p "$TH7"; touch "$T/state/eat_stdin"
install "$TH7" 'y\ny\nn\n' h3; rc=$?
/bin/rm -f "$T/state/eat_stdin"
check "stdin: exit 0" test $rc -eq 0
check "stdin: update prompt still got its answer" no_call softwareupdate
check "stdin: all steps recorded" test "$(state "$TH7")" = "$ALL"

echo "== K: piped output isn't held open by the sudo keep-alive"
touch "$T/state/slow_keepalive"; : > "$LOG"; t0=$(date +%s)
printf 'y\n' | sbx "$TH" "$REPO/scripts/install.sh" | cat > "$T/k1.out"; t1=$(date +%s)
/bin/rm -f "$T/state/slow_keepalive"
check "pipe: output complete" grep -q 'Nothing to run' "$T/k1.out"
check "pipe: returns without waiting on the keep-alive ($((t1-t0))s)" test $((t1-t0)) -lt 4

# ── D: update_configs --commit against a scratch bare remote ──
echo "== D: update_configs.sh --commit"
GITENV=(GIT_CONFIG_GLOBAL=/dev/null GIT_AUTHOR_NAME=sandbox GIT_AUTHOR_EMAIL=sandbox@example.com
        GIT_COMMITTER_NAME=sandbox GIT_COMMITTER_EMAIL=sandbox@example.com)
env "${GITENV[@]}" "$REAL_GIT" clone -q --bare "$REPO" "$T/remote.git"
env "${GITENV[@]}" "$REAL_GIT" clone -q "$T/remote.git" "$T/uc"
cp -R "$REPO/config" "$REPO/meta" "$REPO/scripts" "$REPO/README.md" "$T/uc/"
(cd "$T/uc" && env "${GITENV[@]}" "$REAL_GIT" add -A && env "${GITENV[@]}" "$REAL_GIT" commit -qm baseline \
    && env "${GITENV[@]}" "$REAL_GIT" push -q)
rhead() { "$REAL_GIT" -C "$T/remote.git" rev-parse HEAD; }
uc() { sbx "$TH" env "${GITENV[@]}" bash "$T/uc/scripts/update_configs.sh" --commit > "$T/$1.out" 2>&1; }

h0=$(rhead); uc d1; rc=$?
check "no changes: exit 0" test $rc -eq 0
check "no changes: says nothing to commit" grep -q 'Nothing to commit' "$T/d1.out"
check "no changes: nothing pushed" test "$(rhead)" = "$h0"

echo "# sandbox change" >> "$TH/.zshrc"
sed -i '' 's/email = .*/email = sandbox@example.com/' "$TH/.gitconfig"
uc d2; rc=$?
check "change: exit 0" test $rc -eq 0
check "change: pushed" test "$(rhead)" != "$h0"
check "change: gitconfig email redacted" bash -c "'$REAL_GIT' -C '$T/remote.git' show HEAD:config/.gitconfig | grep -q 'email = <github_no_reply>'"

h1=$(rhead); echo "# $TH/leak" >> "$TH/.zshrc"; uc d3; rc=$?
check "home path: exit 1" test $rc -eq 1
check "home path: names the file" grep -q 'config/.zshrc' "$T/d3.out"
check "home path: nothing pushed" test "$(rhead)" = "$h1"

# ── E: fix 7 control, the rewrite really breaks a plain clone here ──
echo "== E: control for fix 7"
sbx "$TH" "$REAL_GIT" clone -q https://github.com/cpwillis/omz-git-branch.git "$T/ctl" > /dev/null 2>&1; rc=$?
check "plain clone with the rewrite fails" test $rc -ne 0

# ── F: code() in .zshrc ──
echo "== F: code()"
mkdir -p "$T/proj/.vscode" "$T/plain"; touch "$T/proj/.vscode/proj.code-workspace"
out=$(cd "$T" && zsh -fc '
    code_path=stub; stub() { print -r -- "ARGS:$*"; }
    eval "$(sed -n "/^code() {/,/^}/p" "$0")"
    code; code -n; code missing.py; code plain; code proj' "$REPO/config/.zshrc" 2>&1)
check "no args passes through" grep -qx 'ARGS:' <<< "$out"
check "flag passes through" grep -qx 'ARGS:-n' <<< "$out"
check "missing file passes through" grep -qx 'ARGS:missing.py' <<< "$out"
check "plain dir passes through" grep -qx 'ARGS:plain' <<< "$out"
check "workspace dir opens workspace" grep -q 'ARGS:.*/proj/.vscode/proj.code-workspace' <<< "$out"
check "no realpath errors" bash -c "! grep -qi realpath <<< '$out'"

echo "== $PASSED passed, $FAILED failed"
if [[ $FAILED -eq 0 ]]; then rm -rf "$T"; else echo "sandbox kept for inspection: $T"; exit 1; fi
