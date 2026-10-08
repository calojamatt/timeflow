# TimeFlow Privacy Summary

Last reviewed: 2026-10-08

TimeFlow is designed to keep work-time data on the device. The application does
not require an account and does not include cloud synchronization, analytics,
advertising, or a telemetry service.

## Data stored on this device

TimeFlow stores work-session start/end timestamps and notes, planned work
blocks, weekly templates, and reminder preferences in its local SQLite
database. Local notifications are scheduled by the operating system from those
preferences and plans. The data is available to the app on this device only.

## Backups and sharing

Creating a backup or CSV export is user initiated. TimeFlow prepares a file and
opens the platform share interface. The user chooses where the file goes; a
chosen destination may store or transmit a copy under that provider's own
policies. TimeFlow does not receive a copy from that destination. Restoring a
backup replaces the current on-device records after validation and confirmation.

## Deletion

The Backup & Restore screen can permanently delete all TimeFlow records and
cancel scheduled TimeFlow notifications on this device. This action cannot
delete copies previously saved or shared outside the application. Uninstalling
the app also removes its private application data according to the platform.

## Permissions and network

TimeFlow requests notification permission to show local reminders. Backup file
selection uses the platform document picker; the app does not request broad
storage access. The app has no account or network-based data transfer feature.

## Contact and publication status

This document describes the current application behavior; it is not a legal
representation for every jurisdiction. Before public store distribution, the
maintainer should add an appropriate contact address and verify the store
privacy disclosures against the final signed build.
