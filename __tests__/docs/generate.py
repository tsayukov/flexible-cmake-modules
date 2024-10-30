#!/usr/bin/env python3

import os
import re
import sys

from dataclasses import dataclass, field
from typing import Any, ClassVar


@dataclass(eq=False, slots=True)
class WikiPageGenerator:
    """Class for generating an .md file as a wiki page"""
    directory: str
    is_active: bool = field(default=False, init=False)
    n_equal_signs: int = field(default=0, init=False)

    title_forbidden_pattern: ClassVar[re.Pattern] = re.compile(r"[\\/:*?\"<>|]|\s")
    open_pattern: ClassVar[re.Pattern] = re.compile(r"^\s*#\[(=*)\[#github\/wiki\s*$")
    close_pattern: ClassVar[re.Pattern] = re.compile(r"^\s*#\](=*)\]#github\/wiki\s*$")

    def __open(self, n_equal_signs: int):
        if self.is_active:
            raise RuntimeError((f"Current WikiPageGenerator is already active: "
                                "unexpected the opening wiki comment"))
        self.n_equal_signs = n_equal_signs
        self.is_active = True

    def __close(self, n_equal_signs: int):
        if not self.is_active:
            raise RuntimeError((f"Current WikiPageGenerator is not active: "
                                "unexpected the closing wiki comment"))
        if self.n_equal_signs != n_equal_signs:
            raise RuntimeError((f"Expected {self.n_equal_signs} equal signs, "
                                "but got: {n_equal_signs}"))
        self.n_equal_signs = 0
        self.is_active = False

    def __find_first__opening_wiki_comment(self, line_generator: Any) -> bool:
        for line in line_generator:
            m: re.Match | None = re.match(WikiPageGenerator.open_pattern, line)
            if m is not None:
                equal_signs: str = m[1]
                self.__open(len(equal_signs))
                return True
        return False

    def __find_wiki_title(self, line_generator: Any) -> str:
        for line in line_generator:
            index: int = line.find("#")
            if index != -1 and len(line) > index + 1 and line[index + 1] != "#":
                title: str = line[index+1:].strip()
                return re.sub(WikiPageGenerator.title_forbidden_pattern, "-", title)
        raise RuntimeError("The wiki title is not found. Expected form: '# <title>'")

    def __write_to_wiki(self, file: Any, line: str):
        m: re.Match | None = re.match(WikiPageGenerator.close_pattern, line)
        if m is not None:
            equal_signs: str = m[1]
            self.__close(len(equal_signs))
            return

        m = re.match(WikiPageGenerator.open_pattern, line)
        if m is not None:
            equal_signs: str = m[1]
            self.__open(len(equal_signs))
            return

        if not self.is_active:
            return

        file.write(f"{line}")

    def generate_from(self, line_generator: Any):
        """Generate an .md file in `self.directory` with documentation from `line_generator`"""
        if not self.__find_first__opening_wiki_comment(line_generator):
            return

        wiki_title: str = self.__find_wiki_title(line_generator)
        file_path: str = os.path.join(self.directory, f"{wiki_title}.md")
        with open(file_path, "w", encoding="utf-8") as doc:
            doc.write(f"# {wiki_title}\n")
            for line in line_generator:
                self.__write_to_wiki(doc, line)


if __name__ == "__main__":
    wiki_dir: str = sys.argv[1]
    module_path: str = sys.argv[2]
    with open(module_path, "r", encoding="utf-8") as module:
        WikiPageGenerator(wiki_dir).generate_from(module)
