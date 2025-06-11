import sqlite3
from enum import StrEnum
from dataclasses import dataclass
from typing import List, Dict

from logger import logger

@dataclass
class Translatable:
    UniqueID: int = -1
    Title: str = ""
    Translation: str = ""
    Archived: bool = False

    @staticmethod
    def fromRow(row: List):
        return Translatable(
            UniqueID=row[0],
            Title=row[1],
            Translation=row[2],
            Archived=row[3] == 1
        )

class TranslationTables(StrEnum):
    Unknown = '** Unknown **'
    Item = 'Item'
    Screen = 'Screen'
    Menu = 'Menu'
    Misc = 'Misc'

class TranslationRepo:
    path: str = ''

    _lists: Dict[TranslationTables, List[Translatable]] = {}


    def __init__(self, path: str):
        self.path = path

    def readTranslations(self, table: TranslationTables):
        db = sqlite3.connect(self.path)
        cursor = db.cursor()
        cursor.execute(f"SELECT UniqueID, Title, Translation, Archived FROM {table.value}")
        rows = cursor.fetchall()
        l = self._lists.get(table, [])
        l.clear()
        for row in rows:
            t = Translatable.fromRow(row)
            l.append(t)
        cursor.close()
        db.close()

    def getList(self, table: TranslationTables) -> List[Translatable]:
        if table == TranslationTables.Unknown:
            logger.error("Cannot retrieve items from an unknown table.")
            return []
        if table not in self._lists:
            self._lists[table] = []
            self.readTranslations(table)
        
        return self._lists[table]

    def clearList(self, table: TranslationTables):
        if table in self._lists:
            self._lists[table].clear()

    def updateTranslation(self, table: TranslationTables, item: Translatable):
        db = sqlite3.connect(self.path)
        cursor = db.cursor()
        cursor.execute(
            f"UPDATE {table.value} SET Title=?, Translation=?, Archived=? WHERE UniqueID=?",
            (item.Title, item.Translation, int(item.Archived), item.UniqueID)
        )
        db.commit()
        cursor.close()
        db.close()
