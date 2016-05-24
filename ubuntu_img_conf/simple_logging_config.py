#!/usr/bin/env python
import logging
import logging.config
import os, stat

os.system("touch /tmp/tttt")
os.chmod("/tmp/tttt", (stat.S_IWOTH | stat.S_IROTH))
logging.config.fileConfig('logging.conf')

# create logger
logger = logging.getLogger('simpleExample')

# 'application' code
logger.debug('debug message')
logger.info('info message')
logger.warn('warn message')
logger.error('error message')
logger.critical('critical message')
