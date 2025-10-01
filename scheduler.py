#!/usr/bin/env python3
import schedule
import time
import os
from datetime import datetime

# Import your main scraping function
# Adjust this based on actual project structure
from main import run_scraper

def job():
    print(f"[{datetime.now()}] Starting scrape job...")
    try:
        run_scraper()
        print(f"[{datetime.now()}] Scrape completed successfully")
    except Exception as e:
        print(f"[{datetime.now()}] Error during scrape: {e}")

# Get interval from environment variable (default 1 hour)
interval = int(os.getenv('SCRAPE_INTERVAL', 3600))

if interval > 0:
    # Schedule the job
    schedule.every(interval).seconds.do(job)
    
    print(f"Scheduler started. Running every {interval} seconds")
    
    # Run once immediately
    job()
    
    # Keep the scheduler running
    while True:
        schedule.run_pending()
        time.sleep(60)
else:
    # Run once and exit
    job()
