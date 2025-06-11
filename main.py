# This Python file uses the following encoding: utf-8
import sys, os, sqlite3
from pathlib import Path
import argparse

from PySide6.QtCore import QSettings
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from logger import logger
from translation import Translatable, TranslationRepo, TranslationTables
from ItemModel import TranslatableModel

# ============================================================================
# Parameters =================================================================
# ============================================================================

ORG_NAME = "CLSInfo"
APP_NAME = "POSiTrad"

DB_PATH = "trad.db"
""" Default location of the POSiTrad database """
WORKING_QM_PATH = "tempqm.mdb"
""" Default location of the working qm.mdb file """
DEFAULT_OUTPUT_PATH = "qm.mdb"
""" Default location of the output qm.mdb file """
DEFAULT_POSITOUCH_PATH = "C:\\SC\\"
""" Default location of the qm.mdb file """
DEFAULT_ODBC_CONNECTION_STRING = "DSN=qmdb"

# ============================================================================
# Console arguments ==========================================================
# ============================================================================

parser = argparse.ArgumentParser(
    prog=APP_NAME,
    description="Outil pour faciliter les modifications de menu Positouch",
    epilog="Auteur: Martin Lapierre Pitre (C) CLS Info 2025"
)

parser.add_argument("--translate",
                    help="Génère une traduction.",
                    action="store_true"
                    )

# ============================================================================
# Main =======================================================================
# ============================================================================

if __name__ == "__main__":
    logger.info("Starting POSiTrad...")

    # Check for the POSiTrad database; create if it doesn't exist
    if not os.path.isfile(DB_PATH):
        db = sqlite3.connect(DB_PATH)
        logger.info("Database not found, creating a new one at %s", DB_PATH)
        cursor = db.cursor()
        for f in os.listdir('schema'):
            path = os.path.join('schema', f)
            with open(path, 'r') as script:
                logger.info("Executing schema script %s...", path)
                cursor.executescript(script.read())
        with open('tests.sql', 'r') as script:
            logger.info("Filling database with test data from %s...", 'tests.sql')
            cursor.executescript(script.read()) # For testing purposes

    translationRepo = TranslationRepo(DB_PATH)


    # Launch our GUI
    logger.info("Launching GUI...")
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("CLSInfo")
    app.setApplicationName("POSiTrad")
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"


    itemModel = TranslatableModel(translationRepo)
    itemModel.setItemList(translationRepo.getList(TranslationTables.Item))
    engine.rootContext().setContextProperty("itemModel", itemModel)

    screenModel = TranslatableModel(translationRepo)
    screenModel.setItemList(translationRepo.getList(TranslationTables.Screen))
    engine.rootContext().setContextProperty("screenModel", screenModel)

    menuModel = TranslatableModel(translationRepo)
    menuModel.setItemList(translationRepo.getList(TranslationTables.Menu))
    engine.rootContext().setContextProperty("menuModel", menuModel)

    miscModel = TranslatableModel(translationRepo)
    miscModel.setItemList(translationRepo.getList(TranslationTables.Misc))
    engine.rootContext().setContextProperty("miscModel", miscModel)
    
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)

    code = app.exec()

    logger.info("POSiTrad finished with code %d", code)

    sys.exit(code)