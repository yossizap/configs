"""Exercise installer helpers with local fixtures and no account changes."""
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest
import zipfile


INSTALL = (Path(__file__).resolve().parents[1] / 'install.sh').read_text()


def function(name, next_name):
    start = INSTALL.index(name + '() {')
    end = INSTALL.index('\n' + next_name + '() {', start)
    return INSTALL[start:end]


class InstallerHelperTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def run_bash(self, script, env):
        return subprocess.run(['bash', '-c', script], env={**os.environ, **env},
                              text=True, capture_output=True, timeout=15)

    def test_nvm_on_bash_with_and_without_local_mirror(self):
        nvm_dir = self.root / 'nvm'
        nvm_dir.mkdir()
        (nvm_dir / 'nvm.sh').write_text('''nvm() {
    case "$1" in
        install)
            [ "$2" = 22 ] || return 11
            case $- in *u*) return 12 ;; esac
            if [ "$LOCAL_MIRROR" = true ]; then
                [ "$(curl -fsS "$NVM_NODEJS_ORG_MIRROR/index.tab")" = fixture ] || return 13
            else
                [ "$NVM_NODEJS_ORG_MIRROR" = 'http://example.invalid' ] || return 14
            fi
            [ "$FAIL_INSTALL" != true ] || return 15 ;;
        alias) [ "$2" = default ] && [ "$3" = 22 ] || return 16 ;;
        use) NVM_BIN="$NVM_DIR/versions/node/v22/bin" ;;
        version) printf 'v22.0.0\\n' ;;
        *) return 17 ;;
    esac
}
''')
        script = ('set -euo pipefail\nclone_or_update() { :; }\nrsync() { :; }\n'
                  + function('install_nvm', 'configure_shell_startup')
                  + '\ninstall_nvm\nprintf "PATH_HEAD=%s\\n" "${PATH%%:*}"\n')
        for local_mirror, fail in ((False, False), (True, False), (True, True)):
            with self.subTest(local_mirror=local_mirror, fail=fail):
                repo = self.root / ('local' if local_mirror else 'remote')
                repo.mkdir(exist_ok=True)
                if local_mirror:
                    cache = repo / 'source' / 'node-dist'
                    cache.mkdir(parents=True, exist_ok=True)
                    (cache / 'index.tab').write_text('fixture\n')
                env = dict(REPO_DIR=str(repo), SRC_ROOT=str(repo / 'sources'),
                           NVM_DIR=str(nvm_dir), NVM_SRC_DIR=str(nvm_dir), NVM_REF='master',
                           OFFLINE_MODE='false', LOCAL_MIRROR=str(local_mirror).lower(),
                           FAIL_INSTALL=str(fail).lower(),
                           NVM_NODEJS_ORG_MIRROR='http://example.invalid')
                result = self.run_bash(script, env)
                self.assertEqual(result.returncode != 0, fail, result.stderr)
                if not fail:
                    self.assertIn(f'PATH_HEAD={nvm_dir}/versions/node/v22/bin', result.stdout)

    def test_conda_seed_retries_full_repodata(self):
        script = '''set -euo pipefail
curl() {
    local url='' output=''
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -o) output="$2"; shift 2 ;;
            -*) shift ;;
            *) url="$1"; shift ;;
        esac
    done
    case "$url" in
        */current_repodata.json) printf '{"packages":{}}\\n' > "$output" ;;
        */repodata.json) printf '{"packages.conda":{"conda-standalone-1_single_0.conda":{"name":"conda-standalone","build":"_single_0","timestamp":1}}}\\n' > "$output" ;;
        */conda-standalone-1_single_0.conda) printf 'archive\\n' > "$output" ;;
        *) return 8 ;;
    esac
}
''' + function('seed_conda_standalone', 'install_conda') + '''
archive="$(seed_conda_standalone linux-64 "$TMP_DIR")"
[ "$archive" = "$TMP_DIR/conda-standalone-1_single_0.conda" ]
[ "$(cat "$archive")" = archive ]
'''
        result = self.run_bash(script, dict(CONDA_CHANNEL='http://example.invalid/pkgs/main',
                                             TMP_DIR=str(self.root)))
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_conda_bootstrap_uses_channel_and_ca_bundle(self):
        executable = self.root / 'standalone_conda' / 'conda.exe'
        executable.parent.mkdir()
        executable.write_text('#!/bin/sh\nprintf "%s\\n" "$REQUESTS_CA_BUNDLE" "$@" > "$CAPTURE"\n')
        executable.chmod(0o755)
        archive = self.root / 'conda-standalone-1_single_0.tar.bz2'
        with tarfile.open(archive, 'w:bz2') as tar:
            tar.add(executable, arcname='standalone_conda/conda.exe')
        script = '''set -euo pipefail
find_source_file() { printf '%s\\n' "$ARCHIVE"; }
install_conda_shortcuts() { :; }
''' + function('install_conda', 'maybe_install_conda') + '\ninstall_conda\n'
        capture = self.root / 'conda-args'
        ca_bundle = self.root / 'fronting-ca.pem'
        result = self.run_bash(script, dict(ARCHIVE=str(archive), CAPTURE=str(capture),
                                             CONDA_DIR=str(self.root / 'conda'),
                                             CONDA_CHANNEL='https://mirror.example/pkgs/main',
                                             REQUESTS_CA_BUNDLE=str(ca_bundle),
                                             INSTALL_MAMBA='false', OFFLINE_MODE='true'))
        self.assertEqual(result.returncode, 0, result.stderr)
        args = capture.read_text().splitlines()
        self.assertEqual(args[0], str(ca_bundle))
        self.assertIn('https://mirror.example/pkgs/main', args)
        self.assertIn('--repodata-fn', args)
        self.assertIn('repodata.json', args)

    def test_nerd_font_uses_latest_zip_release(self):
        archive = self.root / 'JetBrainsMono.zip'
        with zipfile.ZipFile(archive, 'w') as bundle:
            bundle.writestr('JetBrainsMonoNerdFontMono-Regular.ttf', b'font')
        start = INSTALL.index('install_nerd_font() (')
        end = INSTALL.index('\nconfigure_terminal_font() {', start)
        script = '''set -euo pipefail
find_source_file() { printf '%s\\n' "$ARCHIVE"; }
fc-cache() { :; }
curl() {
    [ "$4" = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip' ] || return 7
    cp "$ARCHIVE" "$6"
}
''' + INSTALL[start:end] + '''
install_nerd_font
test -f "$USER_FONT_DIR/JetBrainsMonoNerdFontMono-Regular.ttf"
'''
        for offline in ('false', 'true'):
            with self.subTest(offline=offline):
                env = dict(ARCHIVE=str(archive), OFFLINE_MODE=offline,
                           NERD_FONT_NAME='JetBrainsMono', NERD_FONT_REFRESH='true',
                           NERD_FONT_FAMILY='JetBrainsMono Nerd Font Mono',
                           USER_FONT_DIR=str(self.root / offline))
                result = self.run_bash(script, env)
                self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
