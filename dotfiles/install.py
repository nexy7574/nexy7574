#!/usr/bin/python3

# Script to replace install.bash, with python, since the bash script is getting a bit icky.
import sys
import os
import shutil
import time
import subprocess
from pathlib import Path

try:
    import rich
    import click
except ImportError:
    requirements = [
        "click",
        "rich",
        "pip",
        "wheel",
        "setuptools"
    ]
    print("Missing dependencies for dotfiles. Installing now.", file=sys.stderr)
    time.sleep(1)
    subprocess.run([sys.executable, "-m", "pip", "install", "-U", *requirements])
    print("Dependencies installed. Please run the script again.", file=sys.stderr)
    sys.exit(1)

console = rich.get_console()


APT_DEPENDENCIES = [
    'build-essential',
    'libssl-dev',
    'zlib1g-dev',
    'libbz2-dev',
    'libreadline-dev',
    'libsqlite3-dev',
    'curl',
    'llvm',
    'libncursesw5-dev',
    'xz-utils',
    'tk-dev',
    'libxml2-dev',
    'libxmlsec1-dev',
    'libffi-dev',
    'liblzma-dev'
]

PACMAN_DEPENDENCIES = ['base-devel', 'openssl', 'zlib', 'xz', 'tk', 'readline', 'sqlite3', 'libffi']


def get_yes_or_no() -> bool:
    """Waits until y or n keys are pressed"""
    while True:
        try:
            char = click.getchar().lower()[0]
            if char not in ("y", "n"):
                click.echo("\b", nl=False)
            else:
                click.echo()
                return char == "y"
        except KeyboardInterrupt:
            return False


def is_apt() -> bool:
    """Indicates if the current system is using apt or not."""
    return Path("/etc/apt").exists()


def is_pacman() -> bool:
    """Indicates if the current system is using pacman or not."""
    return Path("/etc/pacman.d").exists()


def install_packages(*packages) -> subprocess.CompletedProcess:
    """Installs selected packages."""
    cmd = ["sudo", "apt", "install", "-y"] if is_apt() else ['sudo', 'pacman', '-Syu', '--noconfirm']
    result: subprocess.CompletedProcess = subprocess.run(
        cmd + list(packages),
        capture_output=True,
        encoding="utf-8"
    )
    return result


def install_build_dependencies():
    """Installs dependencies required to build packages."""
    deps = APT_DEPENDENCIES if is_apt() else (PACMAN_DEPENDENCIES if is_pacman() else None)
    if deps is None:
        raise RuntimeError("Unsupported package manager.")

    with console.status("[bold green]Installing dependencies"):
        result = install_packages(*deps)
    if result.returncode != 0:
        console.print("[red]Return code for %r was %d." % (" ".join(result.args[:2]), result.returncode))
        console.print("Would you like to view the command output? (Y/N) ")
        if get_yes_or_no():
            click.echo_via_pager("STDOUT:\n\n" + result.stdout)
            click.echo_via_pager("STDERR:\n\n" + result.stderr)
        return False
    return True


def install_runtime_dependencies():
    with console.status("[bold green]Installing runtime dependencies"):
        result = install_packages("git", "wget", "curl", "zsh", "rsync")


@click.command()
@click.argument("--no-python", "-P", is_flag=True, env_var="NO_PYTHON", help="Disables installing pyenv")
def main():
    """Installs dotfiles and extra tools."""
    console.print(
        ":warning: This script executes `sudo` a lot - you should enable passwordless sudo, at least temporarily."
    )
    if is_apt():
        os.environ["DEBIAN_FRONTEND"] = "noninteractive"
        with console.status("[bold green]Updating apt repositories"):
            subprocess.run(["sudo apt", "update", "-y"], capture_output=True)
    else:
        with console.status("[bold green]Updating pacman database"):
            subprocess.run(["sudo pacman", "-Syu", "--noconfirm"], capture_output=True)

    install_runtime_dependencies()


if __name__ == "__main__":
    main()
