from dataclasses import dataclass

@dataclass
class Translatable:
    UniqueID: int = -1
    Title: str = ""
    Translation: str = ""
    Archived: bool = False