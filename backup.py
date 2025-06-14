import os
import time
import zipfile
import hashlib
from typing import List, Any

from PySide6.QtCore import QAbstractListModel, QObject, QModelIndex, QPersistentModelIndex, Qt, QByteArray, Slot

from logger import logger

class BackupManager(QAbstractListModel):

    def __init__(self, fileName: str, folder: str, backupCount: int, filesToBackup: List[str]) -> None:
        super().__init__()
        self.fileName = fileName
        self.folder = folder
        self.backupCount = backupCount
        self.filesToBackup = filesToBackup
        self.tempFileName = "backup.tmp"
    
    def _createArchive(self, archiveName: str) -> None:
        with zipfile.ZipFile(archiveName, 'w', zipfile.ZIP_DEFLATED) as backupZip:
            for f in self.filesToBackup:
                if os.path.exists(f):
                    logger.info(f"Adding file {f} to backup zip.")
                    backupZip.write(f)
                else:
                    logger.warning(f"File {f} does not exist, skipping this file for backup.")

    def _shiftFileNames(self):
        for i in range(self.backupCount-1, 0, -1):
            name = self.fileName.format(i)
            path = os.path.join(self.folder, name)
            if os.path.isfile(path):
                newName = self.fileName.format(i + 1)
                newPath = os.path.join(self.folder, newName)
                logger.info(f"Moving {path} to {newPath}")
                os.rename(path, newPath)
        

    @Slot(result=List[str])
    def getExistingBackups(self) -> List[str]:
        """ Get a list of existing backups in the backup folder. """
        if not self.probeFolder():
            logger.error(f"Backup folder {self.folder} does not exist.")
            return []
        
        backups = []
        for i in range(1, self.backupCount + 1):
            backupName = self.fileName.format(i)
            backupPath = os.path.join(self.folder, backupName)
            if os.path.isfile(backupPath):
                backups.append(backupPath)
        
        logger.debug(f"Found {len(backups)} existing backups.")
        return backups
    
    @Slot(str)
    def restore(self, path: str):
        logger.warning("NOT YET IMPLEMENTED")
        NotImplemented

    def probeFolder(self) -> bool:
        """ Check if the backup folder exists. """
        return os.path.exists(self.folder)
    
    def createBackup(self) -> None:
        """ Create a backup of the specified file. """
        if self.backupCount <= 0:
            logger.info("Backup count is set to 0, skipping backup creation.")
            return
        if self.folder is None or len(self.folder) == 0:
            logger.error("Backup folder is not set, skipping backup creation.")
            return
        
        logger.info(f"Creating backup in folder: {self.folder} with file name: {self.fileName.format(self.backupCount)}")
        if not self.probeFolder():
            logger.info(f"Backup folder {self.folder} does not exist, creating it.")
            os.mkdir(self.folder)

        newBackupName = self.fileName.format(1)
        newPath = os.path.join(self.folder, newBackupName)

        if os.path.isfile(self.tempFileName):
            os.remove(self.tempFileName)
        self._createArchive(self.tempFileName)

        # Check if the current data is the same as the last backup
        if os.path.isfile(newPath):
            latestBackupChecksum = 0
            currentChecksum = 1
            with open(self.tempFileName, 'rb') as f:
                latestBackupChecksum = hashlib.md5(f.read()).hexdigest()
            with open(newPath, 'rb') as f:
                currentChecksum = hashlib.md5(f.read()).hexdigest()
            logger.debug(f"Latest backup checksum: {latestBackupChecksum}, Current checksum: {currentChecksum}")

            if latestBackupChecksum == currentChecksum:
                logger.info("No changes detected, skipping this file for backup.")
                return

        oldestBackup = self.fileName.format(self.backupCount)
        oldestBackupPath = os.path.join(self.folder, oldestBackup)

        if os.path.isfile(oldestBackupPath):
            logger.info(f"Removing oldest backup: {oldestBackupPath}")
            os.remove(oldestBackupPath)

        self._shiftFileNames()

        # Our temp file is the new backup
        os.rename(self.tempFileName, newPath)
        #self._createArchive(newPath)

        logger.info(f"Backup created successfully at {newPath}")

    # The methods below are for the QAbstractListModel implementation

    def data(self, index: QModelIndex | QPersistentModelIndex, role: int = Qt.ItemDataRole.DisplayRole) -> Any:
        row = index.row()
        backups = self.getExistingBackups()
        if not index.isValid() or row >= len(backups):
            return None
        
        b = backups[row]
        if role == Qt.ItemDataRole.DisplayRole:
            return b
        elif role == Qt.ItemDataRole.UserRole + 1:
            return b
        elif role == Qt.ItemDataRole.UserRole + 2:
            return time.ctime(os.path.getmtime(b))
            
    def roleNames(self) -> dict[int, QByteArray]:
        return {
            Qt.ItemDataRole.UserRole + 1: QByteArray(b'Path'),
            Qt.ItemDataRole.UserRole + 2: QByteArray(b'LastModified')
        }
    
    def rowCount(self, parent: QModelIndex | QPersistentModelIndex = QModelIndex()) -> int:
        backups = self.getExistingBackups()
        return len(backups)