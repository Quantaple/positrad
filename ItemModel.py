from typing import List, Any

from PySide6.QtCore import QAbstractListModel, QObject, QModelIndex, QPersistentModelIndex, Qt, QByteArray, Slot

from translation import Translatable, TranslationRepo, TranslationTables
from logger import logger



# Basé sur https://forum.qt.io/topic/144918/pyside6-pass-custom-listmodel-to-listview/3
class TranslatableModel(QAbstractListModel):
    _itemList: List[Translatable] = []

    _displayedList: List[Translatable] = []

    _repo: TranslationRepo

    _showArchived: bool = True
    _showTranslated: bool = True

    def __init__(self, repo: TranslationRepo):
        super().__init__()

        self._repo = repo

    def setItemList(self, itemList: List[Translatable]):
        self._itemList = itemList
        self._displayedList = itemList

    @Slot(bool,bool)
    def setFilters(self, showArchived: bool, showTranslated: bool):
        self._showArchived = showArchived
        self._showTranslated = showTranslated
        self._displayedList = [t for t in self._itemList if (showArchived or not t.Archived) and (showTranslated or len(t.Translation) == 0)]
        print(f"Model was reset to size {len(self._displayedList)}")
        self.refreshList()

    @Slot()
    def refreshList(self):
        self.beginResetModel()
        self._displayedList = [t for t in self._itemList if (self._showArchived or not t.Archived) and (self._showTranslated or len(t.Translation) == 0)]
        print(f"Model was refreshed to size {len(self._displayedList)}")
        self.endResetModel()
        self.layoutChanged.emit()

    @Slot(int, bool)
    def setArchived(self, index: int, archived: bool):
        """ Set the archived status of an item at the given index. """
        if self._displayedList[index].Archived == archived:
            logger.debug(f"No change in archived status for index {index}, keeping {archived}")
            return
        logger.debug(f"Setting archived status for index {index} to {archived}")
        
        item = self._displayedList[index]
        item.Archived = archived
        self._repo.updateTranslation(TranslationTables.Item, item)
        logger.info(f"Item {item.UniqueID} archived status set to {archived}")

    @Slot(int, str)
    def setTranslation(self, index: int, translation: str):
        """ Set the translation of an item at the given index. """
        if translation == self._displayedList[index].Translation:
            logger.debug(f"No change in translation for index {index}, keeping '{translation}'")
            return
        
        logger.debug(f"Setting translation for index {index} to '{translation}'")
        
        item = self._displayedList[index]
        item.Translation = translation
        self._repo.updateTranslation(TranslationTables.Item, item)
        logger.info(f"Item {item.UniqueID} translation set to '{translation}'")

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int = Qt.ItemDataRole.DisplayRole) -> Any:
        row = index.row()
        if not index.isValid() or row >= len(self._displayedList):
            return None
        
        item = self._displayedList[row]
        if role == Qt.ItemDataRole.DisplayRole:
            return item.Title
        elif role == Qt.ItemDataRole.UserRole + 1:
            return item.UniqueID
        elif role == Qt.ItemDataRole.UserRole + 2:
            return item.Title
        elif role == Qt.ItemDataRole.UserRole + 3:
            return item.Translation
        elif role == Qt.ItemDataRole.UserRole + 4:
            return item.Archived
            
    def roleNames(self) -> dict[int, QByteArray]:
        return {
            Qt.ItemDataRole.UserRole + 1: QByteArray(b'UniqueID'),
            Qt.ItemDataRole.UserRole + 2: QByteArray(b'Title'),
            Qt.ItemDataRole.UserRole + 3: QByteArray(b'Translation'),
            Qt.ItemDataRole.UserRole + 4: QByteArray(b'Archived')
        }
    
    def rowCount(self, parent: QModelIndex | QPersistentModelIndex = QModelIndex()) -> int:
        return len(self._displayedList)