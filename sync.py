#!/usr/bin/env python

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from os import PathLike
from typing import Optional, Union
from urllib.request import urlopen
import shlex
import shutil
import subprocess


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
        "--force", "-f", action="store_true", help="replace existing files")
    args = parser.parse_args()

    home = Path.home()

    remotes = [
        RemoteFile(
            url=("https://raw.githubusercontent.com/vim-scripts/wombat256.vim/"
                 "26fa8528ff1ac33a5b5039133968a3ee1856890f/colors/wombat256.vim"),
            local_path=home / ".vim/colors/wombat256.vim",
        ),
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

        # bash
        Symlink(path=home / ".bashrc", target="bashrc"),
        Symlink(path=home / ".config/starship.toml", target="starship.toml"),

        # latex
        Symlink(path=home / ".latexmkrc", target="latexmkrc"),

        # nvim
        Symlink(path=home / ".config/nvim/init.lua", target="nvim.lua"),
        Symlink(path=home / ".vimrc", target="vimrc"),
        Symlink(path=home / ".vim/ftplugin/tex.vim", target="tex.vim"),

        # zsh
        Symlink(path=home / ".zshrc", target="zshrc"),
        Symlink(path=home / ".p10k.zsh", target="p10k.zsh"),  # config of p10k
        *(Symlink(path=home / ".zfunc" / tgt.name, target=tgt)
          for tgt in Path("zfunc").iterdir()),
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

    for link in links:
        link.create(force=args.force)
