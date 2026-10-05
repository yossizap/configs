"""Exercise startup and installer shell handling without changing user accounts."""
import os
import pty
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
INSTALL = (ROOT / 'install.sh').read_text()

def function(name):
    return re.search(r'^' + name + r'\(\) \{\n.*?^\}', INSTALL, re.M | re.S)[0]

class ShellStartupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.nvm = self.home / 'custom nvm'
        self.nvm.mkdir()
        (self.nvm / 'nvm.sh').write_text('nvm() { export CONFIGS_TEST_NODE=default; }\n')
        for name in ('.bashrc', '.zshrc'):
            shutil.copy(ROOT / name, self.home / name)
        self.env = dict(os.environ, HOME=str(self.home), NVM_DIR=str(self.nvm), TERM='dumb')
        self.env.pop('ZDOTDIR', None)
        self.env.pop('BASH_ENV', None)

    def run_bash(self, body, check=True):
        p = subprocess.run(['bash', '-c', body], env=self.env, text=True,
                           capture_output=True, timeout=15)
        if check:
            self.assertEqual(p.returncode, 0, p.stderr)
        return p

    def test_interactive_bash_and_zsh_load_nvm(self):
        for shell in ('bash', 'zsh'):
            with self.subTest(shell=shell):
                p = subprocess.run([shell, '-ic', 'command -v nvm >/dev/null && test "$CONFIGS_TEST_NODE" = default'],
                                   env=self.env, capture_output=True, text=True, timeout=15)
                self.assertEqual(p.returncode, 0, p.stderr)

    def test_persisted_custom_path_and_login_profile(self):
        # Check all three Bash profile precedence cases and idempotence.
        for profile in ('.bash_profile', '.bash_login', '.profile'):
            for candidate in ('.bash_profile', '.bash_login', '.profile'):
                (self.home / candidate).unlink(missing_ok=True)
            (self.home / profile).write_text('# user settings\n')
            self.run_bash(function('configure_shell_startup') + '\nconfigure_shell_startup\nconfigure_shell_startup')
            content = (self.home / profile).read_text()
            self.assertEqual(content.count('# >>> configs bash login >>>'), 1)
            env = dict(self.env)
            env.pop('NVM_DIR')
            # Source the selected login profile explicitly: /etc/profile can reset
            # HOME in a test process, independently of the user's startup files.
            p = subprocess.run(['bash', '--norc', '-ic', '. "$HOME/' + profile + '"; command -v nvm >/dev/null && test "$CONFIGS_TEST_NODE" = default'],
                               env=env, text=True, capture_output=True, timeout=15)
            self.assertEqual(p.returncode, 0, p.stderr)

    def shell_body(self, login_shell, change='false', chsh='return 1'):
        return '\n'.join([
            'set -e', 'INSTALL_USER=testuser; SUDO=; CHANGE_DEFAULT_SHELL=' + change,
            'configured_login_shell() { printf "%s\\n" "' + login_shell + '"; }',
            'should_run() { [ "$1" = true ]; }', 'chsh() { ' + chsh + '; }',
            function('ensure_default_zsh'), 'ensure_default_zsh'])

    def test_existing_zsh_uses_account_not_stale_shell_env(self):
        body = self.shell_body(shutil.which('zsh')) + '\ntest "${SHELL##*/}" = zsh'
        self.env['SHELL'] = '/bin/bash'
        self.run_bash(body)

    def test_refusing_shell_change_is_error(self):
        p = self.run_bash(self.shell_body('/bin/bash'), check=False)
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('must be zsh', p.stderr)

    def test_failed_chsh_is_error(self):
        p = self.run_bash(self.shell_body('/bin/bash', 'true'), check=False)
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('Failed to set zsh', p.stderr)

    def test_chsh_success_without_account_change_is_error(self):
        p = self.run_bash(self.shell_body('/bin/bash', 'true', 'return 0'), check=False)
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('not an executable zsh', p.stderr)

    def test_terminal_refresh_executes_interactive_login_zsh(self):
        (self.home / '.zshrc').write_text('[[ -o interactive && -o login ]] || exit 9\nprint CONFIGS_REFRESHED\nexit 0\n')
        body = 'configured_login_shell() { echo "' + shutil.which('zsh') + '"; }\n' + function('refresh_default_shell') + '\nrefresh_default_shell\nexit 19'
        master, slave = pty.openpty()
        try:
            proc = subprocess.Popen(['bash', '-c', body], stdin=slave, stdout=slave,
                                    stderr=slave, env=self.env)
            os.close(slave)
            slave = None
            try:
                proc.wait(timeout=15)
            finally:
                if proc.poll() is None:
                    proc.kill()
                    proc.wait()
            output = b''
            while True:
                try:
                    chunk = os.read(master, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                output += chunk
            self.assertEqual(proc.returncode, 0, output.decode(errors='replace'))
            self.assertIn(b'CONFIGS_REFRESHED', output)
        finally:
            os.close(master)
            if slave is not None:
                os.close(slave)

    def test_batch_refresh_finishes_and_rejects_wrong_shell(self):
        for shell, success in ((shutil.which('zsh'), True), ('/bin/bash', False)):
            p = self.run_bash('configured_login_shell() { echo "' + shell + '"; }\n' +
                              function('refresh_default_shell') + '\nrefresh_default_shell', check=False)
            self.assertEqual(p.returncode == 0, success, p.stderr)

if __name__ == '__main__':
    unittest.main()
