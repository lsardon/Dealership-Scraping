#!/usr/bin/env python3
import os
import sys
import time
import logging
from datetime import datetime
import schedule

# Add the project directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Configure logging
logging.basicConfig(
    level=os.getenv('LOG_LEVEL', 'INFO'),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('/app/logs/scraper.log')
    ]
)
logger = logging.getLogger(__name__)

def run_scrape():
    """Run the main scraping logic"""
    logger.info("Starting scrape job...")
    try:
        # Import and run your existing scraper
        # Adjust this import based on actual file structure
        from scraper import main as scraper_main
        scraper_main()
        logger.info("Scrape completed successfully")
    except Exception as e:
        logger.error(f"Scrape failed: {str(e)}", exc_info=True)

def main():
    # Get interval from environment
    interval = int(os.getenv('SCRAPE_INTERVAL', 3600))
    
    if interval > 0:
        # Schedule recurring job
        logger.info(f"Scheduling scraper to run every {interval} seconds")
        schedule.every(interval).seconds.do(run_scrape)
        
        # Run once on startup
        run_scrape()
        
        # Keep running
        while True:
            schedule.run_pending()
            time.sleep(60)
    else:
        # Run once and exit
        run_scrape()

if __name__ == "__main__":
    main()
