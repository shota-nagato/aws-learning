import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def lambda_handler(event, context):
  logger.info(f"Received event: {json.dumps(event)}")
  logger.info(f"Context: {context}")
  return {
    "hookStatus": "IN_PROGRESS"
  }
