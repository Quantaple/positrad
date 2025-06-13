import os
import zipfile
from typing import List

from logger import logger

class BackupManager:

    def __init__(self, fileName: str, folder: str, backupCount: int, filesToBackup: List[str]) -> None:
        self.fileName = fileName
        self.folder = folder
        self.backupCount = backupCount
        self.filesToBackup = filesToBackup

    def probeFolder(self) -> bool:
        """ Check if the backup folder exists. """
        return os.path.exists(self.folder)
    
    def createBackup(self) -> None:
        """ Create a backup of the specified file. """
        logger.info(f"Creating backup in folder: {self.folder} with file name: {self.fileName} and backup count: {self.backupCount}")
        if not self.probeFolder():
            logger.info(f"Backup folder {self.folder} does not exist, creating it.")
            os.mkdir(self.folder)

        oldestBackup = self.fileName.format(self.backupCount)
        oldestBackupPath = os.path.join(self.folder, oldestBackup)

        if os.path.isfile(oldestBackupPath):
            logger.info(f"Removing oldest backup: {oldestBackupPath}")
            os.remove(oldestBackupPath)

        for i in range(self.backupCount-1, 0, -1):
            name = self.fileName.format(i)
            path = os.path.join(self.folder, name)
            if os.path.isfile(path):
                newName = self.fileName.format(i + 1)
                newPath = os.path.join(self.folder, newName)
                os.rename(path, newPath)

        # Create our new backup
        newBackupName = self.fileName.format(1)
        newPath = os.path.join(self.folder, newBackupName)
        with zipfile.ZipFile(newPath, 'w', zipfile.ZIP_DEFLATED) as backupZip:
            for f in self.filesToBackup:
                if os.path.exists(f):
                    logger.info(f"Adding file {f} to backup zip.")
                    backupZip.write(f, arcname=os.path.basename(newPath))
                else:
                    logger.warning(f"File {f} does not exist, skipping backup.")

        logger.info(f"Backup created successfully at {newPath}")