#!/usr/bin/env -S uv run

from __future__ import annotations

import hashlib
import shutil
import stat
import subprocess
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path
from urllib.request import urlopen


@dataclass(frozen=True)
class Symlink:
    path: Path
    target: str | Path

    def create(self, force: bool) -> None:
        print(f"creating {self.path} -> {self.target}")
        target = Path(self.target).resolve()
        if force:
            self.path.unlink(missing_ok=True)
        if self.path.exists():
            if self.path.resolve() != target:
                print(f"    ERROR: {self.path} exists")
        else:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.path.symlink_to(target)


@dataclass(frozen=True)
class RemoteContent:
    url: str

    def get(self) -> bytes:
        with urlopen(self.url) as response:
            return response.read()


@dataclass(frozen=True)
class RemoteFile:
    url: str
    local_path: Path

    def download(self, force: bool) -> None:
        print(f"fetching {self.local_path}")
        if self.local_path.exists() and not force:
            print("    already exists")
        else:
            self.local_path.parent.mkdir(parents=True, exist_ok=True)
            _ = self.local_path.write_bytes(RemoteContent(self.url).get())


@dataclass(frozen=True)
class NvimApp:
    local_dir: Path
    release: str = "stable"
    asset_name: str = "nvim-linux-x86_64.appimage"

    @property
    def _release_url(self) -> str:
        return f"https://github.com/neovim/neovim/releases/download/{self.release}"

    @property
    def _appimage_path(self) -> Path:
        return self.local_dir / "nvim.appimage"

    @property
    def _appimage(self) -> RemoteContent:
        return RemoteContent(url=f"{self._release_url}/{self.asset_name}")

    @cached_property
    def _shasum(self) -> str:
        rc = RemoteContent(url=f"{self._release_url}/shasum.txt")
        shasums = rc.get().decode()
        for ln in shasums.splitlines():
            checksum, asset = ln.split()
            if asset == self.asset_name:
                return checksum
        raise RuntimeError(f"checksum not found for {self.asset_name}")

    def download(self) -> Path:
        """Fetch nvim app, return path of executable."""
        print("Downloading nvim...")
        self.local_dir.mkdir(parents=True, exist_ok=True)
        appimage = self._appimage.get()
        sha256 = hashlib.sha256()
        sha256.update(appimage)
        if sha256.hexdigest() != self._shasum:
            raise RuntimeError("sha256 of nvim doesn't match")
        _ = self._appimage_path.write_bytes(appimage)
        stats = self._appimage_path.stat()
        self._appimage_path.chmod(stats.st_mode | stat.S_IXUSR)
        bare_img = subprocess.run(
            args=[f"{self._appimage_path}", "--version"],
            capture_output=True,
        )
        if bare_img.returncode == 0:
            return self._appimage_path
        print("    extracting image...")
        _ = subprocess.run(
            args=[self._appimage_path.resolve(), "--appimage-extract"],
            check=True,
            capture_output=True,
            cwd=self.local_dir,
        )
        return self.local_dir / "squashfs-root/usr/bin/nvim"


@dataclass(frozen=True)
class FileInGitRepo:
    url: str
    local_clone: Path
    file_in_clone: str | Path
    substitute: Path | None = None

    @property
    def _fetched_path(self) -> Path:
        return self.local_clone / self.file_in_clone

    def fetch(self) -> Path:
        print(f"fetching {self._fetched_path}")
        if self.substitute is not None and self.substitute.exists():
            print(f"    using {self.substitute} instead")
            return self.substitute
        if self.local_clone.exists():
            print("    updating local clone")
            _ = subprocess.run(
                args=("git", "pull"),
                check=True,
                cwd=self.local_clone,
            )
        else:
            print("    cloning repository")
            _ = subprocess.run(
                args=(
                    "git",
                    "clone",
                    "--filter",
                    "blob:none",
                    self.url,
                    self.local_clone,
                ),
                check=True,
            )
        if self._fetched_path.exists():
            return self._fetched_path
        raise RuntimeError(f"{self._fetched_path} does not exist")


@dataclass(frozen=True)
class PyTool:
    name: str
    with_deps: tuple[str, ...] = ()

    def install(self) -> None:
        print(f"installing {self.name} with uv")
        cmd = ["uv", "tool", "install", "--upgrade", self.name]
        for dep in self.with_deps:
            cmd.extend(("--with", dep))
        _ = subprocess.run(cmd, check=True)


if __name__ == "__main__":
    import argparse

    @dataclass
    class Args:
        force: bool = False

    parser = argparse.ArgumentParser()
    _ = parser.add_argument(
        "--force", "-f", action="store_true", help="replace existing files"
    )
    args = parser.parse_args(namespace=Args())

    home = Path.home()
    config = home / ".config"

    remotes = [
        RemoteFile(
            url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
            local_path=home / ".vim/autoload/plug.vim",
        ),
    ]
    for remote in remotes:
        remote.download(force=args.force)

    links = [
        # terminal
        Symlink(path=home / ".alias", target="alias"),
        Symlink(path=home / ".tmux.conf", target="tmux.conf"),
        Symlink(path=config / "wezterm/wezterm.lua", target="wezterm.lua"),
        # bash
        Symlink(path=home / ".bashrc", target="bashrc"),
        Symlink(path=config / "starship.toml", target="starship.toml"),
        # latex
        Symlink(path=home / ".latexmkrc", target="latexmkrc"),
        # nvim
        Symlink(path=config / "nvim/init.lua", target="nvim.lua"),
        Symlink(path=config / "nvim/lua/plugins.lua", target="nvim_plugins.lua"),
        Symlink(path=config / "nvim/lua/lsp_custom.lua", target="nvim_lsp.lua"),
        Symlink(path=home / ".vimrc", target="vimrc"),
        # zsh
        Symlink(path=home / ".zshrc", target="zshrc"),
        Symlink(path=home / ".p10k.zsh", target="p10k.zsh"),  # config of p10k
        *(
            Symlink(path=home / ".zfunc" / tgt.name, target=tgt)
            for tgt in Path("zfunc").iterdir()
        ),
    ]

    zsh_gits = Path(".zsh_gits")
    p10k_theme = FileInGitRepo(
        url="https://github.com/romkatv/powerlevel10k.git",
        local_clone=zsh_gits / "powerlevel10k",
        file_in_clone="powerlevel10k.zsh-theme",
        substitute=Path("/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"),
    )
    links.append(Symlink(path=home / ".p10ktheme", target=p10k_theme.fetch()))
    zsh_hl = FileInGitRepo(
        url="https://github.com/zsh-users/zsh-syntax-highlighting.git",
        local_clone=zsh_gits / "zsh-syntax-highlighting",
        file_in_clone="zsh-syntax-highlighting.zsh",
        substitute=Path(
            "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        ),
    )
    links.append(Symlink(path=home / ".zshsynthl", target=zsh_hl.fetch()))

    py_packs = [
        PyTool("basedpyright"),
        PyTool("ruff"),
        PyTool("fortls"),
    ]

    if shutil.which("nvim") is None:
        nvim = NvimApp(local_dir=Path(".nvim")).download()
        links.append(Symlink(path=home / ".local/bin/nvim", target=nvim))

    for link in links:
        link.create(force=args.force)

    # could try to install uv if not present
    for pack in py_packs:
        pack.install()
