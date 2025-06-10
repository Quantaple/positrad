import logging
from logging.handlers import TimedRotatingFileHandler

# Codé par Alexis

LOG_FILENAME = '.\\POSiTrad.log'
# Define custom logging levels in a dictionary
CUSTOM_LEVELS = {
    "INFO" : 20,
    "LINE" : 21,
}

# Dynamically add custom levels and methods to the logger
for level_name, level_value in CUSTOM_LEVELS.items():
    logging.addLevelName(level_value, level_name)

    def custom_log_method(self, message="", *args, level=level_value, **kws):
        if self.isEnabledFor(level):
            self._log(level, message, args, **kws)

    setattr(logging.Logger, level_name.lower(), custom_log_method)
    

# Special handling for logger.line() to just log a line
def line_log_method(self, *args, **kws):
    if self.isEnabledFor(CUSTOM_LEVELS["LINE"]):
        self._log(CUSTOM_LEVELS["LINE"], "_"*80, args, **kws)  # 80 underscores as a line

setattr(logging.Logger, "line", line_log_method)

logger = logging.getLogger("mainLogger")
#serverLogger = logging.getLogger()

# You can set the level of each logger independently
logger.setLevel(logging.DEBUG)
#serverLogger.setLevel(logging.DEBUG)

# Set up the timed rotating file handler
file_handler = TimedRotatingFileHandler(LOG_FILENAME, when="midnight", interval=1, backupCount=3)
file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)
logger.addHandler(file_handler)


# Set up the stream handler
stream_handler = logging.StreamHandler()
stream_formatter = logging.Formatter('%(levelname)s: %(message)s')
stream_handler.setFormatter(stream_formatter)
logger.addHandler(stream_handler)