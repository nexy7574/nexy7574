import click
import sys
import os
import subprocess
import platform
from datetime import datetime, timezone
import ipaddress
from pathlib import Path
from typing import Iterable, Dict, List
from urllib.parse import urlparse
import httpx
import json
from tqdm import tqdm


DF = Path(__file__).parent
HOSTS = DF / 'hosts.d'


def download(client: httpx.Client, url: str) -> str:
    """Downloads file from url."""
    parsed = urlparse(url)
    if parsed.scheme == "":
        click.secho(f"Scheme for {url!r} is empty - assuming you meant file://", fg="yellow", err=True)

    if parsed.scheme == 'file' or parsed.scheme == "":
        if os.name == "nt":
            _p = Path(parsed.path.lstrip("/")).resolve()
        else:
            _p = Path(parsed.path).resolve()
        if not _p.exists():
            raise FileNotFoundError(f"File {url!r} does not exist")
        with open(_p, 'r') as f:
            return f.read()
    elif parsed.scheme in ('http', 'https'):
        r = client.get(url)
        r.raise_for_status()
        return r.text
    else:
        raise ValueError(f"Unknown scheme: {parsed.scheme}")


def generate_generic_block(hosts: List[str], name: str) -> str:
    """Generates generic hosts file block."""
    _p = urlparse(name)
    if _p.scheme == "file":
        name = _p.path
        if os.name == "nt":
            name = name.lstrip("/")
        _path = Path(name)
        name = str(_path.relative_to(Path.cwd()))
    x = f"# From: {name}"
    for host in hosts:
        if host.startswith("~"):
            continue
        x += "\n0.0.0.0 " + host
    return x


def generate_adguard_block(hosts: List[str], name: str, unblock: bool = False) -> str:
    """Generates adguard hosts file block."""
    _p = urlparse(name)
    if _p.scheme == "file":
        name = _p.path
        if os.name == "nt":
            name = name.lstrip("/")
        _path = Path(name)
        name = str(_path.relative_to(Path.cwd()))
    x = f"# From: {name}\n"
    for host in hosts:
        print(host)
        if host.startswith("~"):
            prefix = "@@||"
            host = host[1:]
        else:
            prefix = "||"
        x += prefix + host + "\n"
    return x


def generate_generic_hosts_file(hosts: Dict[str, List[str]]) -> str:
    """Generates generic hosts file."""
    ctx = click.get_current_context()
    x = "# nexy7574 host blocklist generator\n# Generation details:\n# | At: {}\n# | By: {} @ {} on {}\n# | With: {}"
    x = x.format(
        datetime.now(timezone.utc).strftime("%c %Z"),
        subprocess.getoutput("whoami"),
        subprocess.getoutput("hostname"),
        platform.platform(),
        " ".join(sys.argv),
    )
    with tqdm(hosts.keys(), desc="Generating hosts file", file=sys.stderr) as bar:
        for name in bar:
            x += "\n\n" + generate_generic_block(hosts[name], name)

    if ctx.params["clean"]:
        lines = tuple(x.splitlines())
        new_lines = []
        with tqdm(lines, desc="Filtering duplicate entries", file=sys.stderr) as bar:
            for line in bar:
                if line == "":
                    new_lines.append(line)
                if line in new_lines:
                    continue
                else:
                    new_lines.append(line)
        click.secho(
            f"Filtered out {(len(lines) - len(new_lines)):,} duplicate entries, resulting in a "
            f"{len(new_lines):,} line hosts file (instead of {len(lines):,}).",
            fg="yellow",
            err=True
        )
    else:
        new_lines = x.splitlines()
    return "\n".join(new_lines)


def generate_adguard_hosts_file(hosts: Dict[str, List[str]]) -> str:
    ctx = click.get_current_context()
    x = "# nexy7574 host blocklist generator\n# Generation details:\n# | At: {}\n# | By: {} @ {} on {}\n# | With: {}"
    x = x.format(
        datetime.now(timezone.utc).strftime("%c %Z"),
        subprocess.getoutput("whoami"),
        subprocess.getoutput("hostname"),
        platform.platform(),
        " ".join(sys.argv),
    )
    with tqdm(hosts.keys(), desc="Generating hosts file", file=sys.stderr) as bar:
        for name in bar:
            x += "\n\n" + generate_adguard_block(hosts[name], name)

    if ctx.params["clean"]:
        lines = tuple(x.splitlines())
        new_lines = []
        bar = tqdm(lines, desc="Filtering duplicate entries", file=sys.stderr)
        with bar:
            for line in bar:
                if line == "":
                    new_lines.append(line)
                if line in new_lines:
                    continue
                else:
                    new_lines.append(line)
        click.secho(
            f"Filtered out {(len(lines) - len(new_lines)):,} duplicate entries, resulting in a "
            f"{len(new_lines):,} line hosts file (instead of {len(lines):,}).",
            fg="yellow",
            err=True
        )
    else:
        new_lines = x.splitlines()
    return "\n".join(new_lines)


@click.command()
@click.option(
    "--clean",
    "-C",
    is_flag=True,
    help="Remove duplicate entries from the hosts file."
)
@click.option(
    "--include",
    "-I",
    multiple=True,
    help="Include additional hosts files. Can be file:// or http(s)://",
)
@click.option(
    "fmt",
    "--format",
    "-F",
    type=click.Choice(["generic", "adguard", "all"]),
    default="generic",
    help="Output format",
)
@click.option(
    "--output",
    "-O",
    type=click.Path(writable=True, allow_dash=True),
    default="./hosts",
    help="Output file",
)
def main(clean: bool, include: Iterable[str], fmt: Iterable[str], output: str):
    """Generates hosts file for adblocking."""
    include = set(include)
    if HOSTS.exists():
        for path in HOSTS.iterdir():
            if path.suffix != ".conf":
                include |= {path.as_uri()}

    session = httpx.Client()
    if (HOSTS / "gen.conf").exists():
        with open(HOSTS / "gen.conf", 'r') as f:
            config = json.load(f)

        for url in config['include']:
            include.add(url)
    else:
        config = {"include": [], "invert": ["file://_allow.txt"]}

    hosts = {}
    with tqdm(include, desc="Downloading hosts files", file=sys.stderr) as bar:
        for url in bar:
            try:
                text = download(session, url)
            except ValueError as e:
                click.secho(f"Failed to download {url!r}: {e}", fg="red", err=True)
                continue
            except httpx.HTTPError as e:
                click.secho(f"Failed to download {url!r}: {e}", fg="red", err=True)
                continue
            else:
                key = url
                if url.lower().startswith("file"):
                    key = os.path.sep.join(url.split(os.path.sep)[-2:])
                hosts[key] = []
                lines = text.splitlines()
                for line in lines:
                    if line.startswith(('!', '#', ';')):
                        continue
                    line = line.split("#", maxsplit=1)[0].strip()  # remove comments
                    if url in config['invert']:
                        line = "~" + line

                    try:
                        ip, host = line.split(maxsplit=1)
                        try:
                            # see if its an IP address
                            ipaddress.ip_address(ip)
                        except ValueError:
                            # it is not an IP address. Multiple host names?
                            for host in line.splitlines():
                                hosts[key].append(host)
                        else:
                            # it is an IP address
                            hosts[key].append(host)
                    except ValueError:
                        # Just plain domain names
                        hosts[key].append(line)

    if fmt != "all":
        with click.open_file(output, 'w') as f:
            if fmt == "generic":
                f.write(generate_generic_hosts_file(hosts))
            elif fmt == "adguard":
                f.write(generate_adguard_hosts_file(hosts))
            else:
                raise ValueError(f"Unknown format: {fmt}")
    else:
        for fn in [f"{output}.adguard.txt", f"{output}.generic.txt"]:
            with click.open_file(fn, 'w') as f:
                if fn.endswith(".adguard.txt"):
                    f.write(generate_adguard_hosts_file(hosts))
                else:
                    f.write(generate_generic_hosts_file(hosts))
        if os.path.exists(output):
            os.remove(output)
        os.symlink(Path.cwd() / f"{output}.generic.txt", Path(output))


if __name__ == "__main__":
    main()
