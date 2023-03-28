#!/usr/bin/env python

from __future__ import annotations

import hashlib
import shlex
import shutil
import stat
import subprocess
from dataclasses import dataclass
from os import PathLike
from pathlib import Path
from typing import Optional, Union
from urllib.request import urlopen


@dataclass(frozen=True)
class Symlink:
    path: Path
    target: Union[str, PathLike]

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
class RemoteFile:
    url: str
    local_path: Path

    def download(self, force: bool) -> None:
        print(f"fetching {self.local_path}")
        if self.local_path.exists() and not force:
            print("    already exists")
        else:
            self.local_path.parent.mkdir(parents=True, exist_ok=True)
            with urlopen(self.url) as response:
                with self.local_path.open("wb") as local:
                    shutil.copyfileobj(response, local)


@dataclass(frozen=True)
class NvimApp:
    local_dir: Path
    image_url: str = (
        "https://github.com/neovim/neovim/releases/download/stable/nvim.appimage"
    )
    sha256_url: str = "https://github.com/neovim/neovim/releases/download/stable/nvim.appimage.sha256sum"

    @property
    def _appimage_path(self) -> Path:
        return self.local_dir / "nvim.appimage"

    @property
    def _appimage(self) -> RemoteFile:
        return RemoteFile(
            url=self.image_url,
            local_path=self._appimage_path,
        )

    @property
    def _sha256_path(self) -> Path:
        return self.local_dir / "nvim.appimage.sha256sum"

    @property
    def _sha256(self) -> RemoteFile:
        return RemoteFile(
            url=self.sha256_url,
            local_path=self._sha256_path,
        )

    def download(self, force: bool) -> Path:
        """Fetch nvim app, return path of executable."""
        print("Downloading nvim...")
        self.local_dir.mkdir(parents=True, exist_ok=True)
        self._appimage.download(force)
        self._sha256.download(force)
        sha256_expected = self._sha256_path.read_text().split()[0]
        sha256 = hashlib.sha256()
        sha256.update(self._appimage_path.read_bytes())
        if sha256.hexdigest() != sha256_expected:
            raise RuntimeError("sha256 of nvim doesn't match")
        stats = self._appimage_path.stat()
        self._appimage_path.chmod(stats.st_mode | stat.S_IXUSR)
        bare_img = subprocess.run(
            args=[f"{self._appimage_path}", "--version"],
            capture_output=True,
        )
        if bare_img.returncode == 0:
            return self._appimage_path
        print("    extracting image...")
        subprocess.run(
            args=[f"./{self._appimage_path.name}", "--appimage-extract"],
            check=True,
            capture_output=True,
            cwd=self.local_dir,
        )
        return self.local_dir / "squashfs-root/usr/bin/nvim"


@dataclass(frozen=True)
class FileInGitRepo:
    url: str
    local_clone: Path
    file_in_clone: Union[str, PathLike]
    substitute: Optional[Path] = None

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
            subprocess.run(
                args=shlex.split("git pull"),
                cwd=self.local_clone,
            )
        else:
            print("    cloning repository")
            subprocess.run(
                args=shlex.split(
                    f"git clone --depth=1 '{self.url}' '{self.local_clone}'"
                ),
            )
        if self._fetched_path.exists():
            return self._fetched_path
        raise RuntimeError(f"{self._fetched_path} does not exist")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--force", "-f", action="store_true", help="replace existing files"
    )
    args = parser.parse_args()

    home = Path.home()

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
        Symlink(path=home / ".alacritty.yml", target="alacritty.yml"),
        Symlink(path=home / ".alias", target="alias"),
        Symlink(path=home / ".tmux.conf", target="tmux.conf"),
        Symlink(path=home / ".config/wezterm/wezterm.lua", target="wezterm.lua"),
        # bash
        Symlink(path=home / ".bashrc", target="bashrc"),
        Symlink(path=home / ".config/starship.toml", target="starship.toml"),
        # latex
        Symlink(path=home / ".latexmkrc", target="latexmkrc"),
        # nvim
        Symlink(path=home / ".config/nvim/init.lua", target="nvim.lua"),
        Symlink(path=home / ".config/nvim/lua/plugins.lua", target="nvim_plugins.lua"),
        Symlink(path=home / ".config/nvim/snippets/_.snippets", target="nvim.snippets"),
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

    if shutil.which("nvim") is None:
        nvim = NvimApp(local_dir=Path(".nvim")).download(args.force)
        links.append(Symlink(path=home / ".local/bin/nvim", target=nvim))

    for link in links:
        link.create(force=args.force)
