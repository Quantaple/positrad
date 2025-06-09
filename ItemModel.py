from typing import List, Any

from translation import Translatable

from PySide6.QtCore import QAbstractListModel, QObject, QModelIndex, Qt, QByteArray, Slot

# Basé sur https://forum.qt.io/topic/144918/pyside6-pass-custom-listmodel-to-listview/3
class ItemModel(QAbstractListModel):
    _itemList: List[Translatable] = []

    _displayedList: List[Translatable] = []

    def __init__(self):
        super().__init__()

    def setItemList(self, itemList: List[Translatable]):
        self._itemList = itemList
        self._displayedList = itemList

    @Slot(bool,bool)
    def setFilters(self, showArchived: bool, showTranslated: bool):
        self.beginResetModel()
        self._displayedList = [t for t in self._itemList if showArchived or not t.Archived and showTranslated or len(t.Translation) == 0]
        self.endResetModel()
        self.layoutChanged.emit()


    def data(self, index: QModelIndex, role: int = Qt.ItemDataRole.DisplayRole) -> Any:
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
            Qt.ItemDataRole.UserRole + 1: b'UniqueID',
            Qt.ItemDataRole.UserRole + 2: b'Title',
            Qt.ItemDataRole.UserRole + 3: b'Translation',
            Qt.ItemDataRole.UserRole + 4: b'Archived'
        }
    
    def rowCount(self, index: QModelIndex = QModelIndex()) -> int:
        return len(self._displayedList)