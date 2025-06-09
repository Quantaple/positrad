# This Python file uses the following encoding: utf-8
import sys, os
from pathlib import Path
import argparse

from PySide6.QtCore import QSettings
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from translation import Translatable
from ItemModel import ItemModel

# ============================================================================
# Parameters =================================================================
# ============================================================================

ORG_NAME = "CLSInfo"
APP_NAME = "POSiTrad"

DEFAULT_DB_PATH = "trad.db"
""" Default location of the POSiTrad database """
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

testItems = [
    Translatable(UniqueID=1000001, Title="PT TARTARE BOEUF", Translation="SM BEEF TARTAR", Archived=False),
    Translatable(UniqueID=1000002, Title="GR TARTARE BOEUF", Translation="LG BEEF TARTAR", Archived=False),
    Translatable(UniqueID=1000003, Title="PT TARTARE SAUMON", Translation="SM SALMON TARTAR", Archived=False),
    Translatable(UniqueID=1000004, Title="GR TARTARE SAUMON", Translation="", Archived=False),
    Translatable(UniqueID=1000005, Title="PT TARTARE CREV", Translation="SM SHRIMP TARTAR", Archived=True),
    Translatable(UniqueID=1000006, Title="LG TARTARE CREV", Translation="LG SHRIMP TARTAR", Archived=True)
]

if __name__ == "__main__":

    # Launch our GUI
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("CLSInfo")
    app.setApplicationName("POSiTrad")
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "main.qml"


    itemModel = ItemModel()
    itemModel.setItemList(testItems)
    engine.rootContext().setContextProperty("itemModel", itemModel)
    
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)

    code = app.exec()

    sys.exit(code)