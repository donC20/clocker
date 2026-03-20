# World Clock App Blueprint

## Overview

This document outlines the plan for creating a "World Clock" application using Flutter. The app will display the current time for multiple, user-configurable time zones on a single screen. It is designed to be a "never-sleep" display, running in full-screen landscape mode on Android devices.

## Core Features

*   **Multi-Time Zone Display:** Show clocks for various user-selected time zones.
*   **Full-Screen Landscape Mode:** The application will lock into a full-screen, landscape orientation for an immersive experience.
*   **Always-On Display:** The screen will remain on as long as the app is active.
*   **User-Configurable Time Zones:** Users will be able to add, remove, and arrange the time zone clocks on the screen.

## Design and Style

*   **Theme:** A modern, visually appealing theme with a dark background to be easy on the eyes for a constantly-on display.
*   **Typography:** Clear, legible fonts will be used, with emphasis on the time display.
*   **Layout:** A flexible layout that allows users to arrange the clocks.

## Technical Implementation Plan

1.  **Project Setup:**
    *   **Done:** Configure the Android application to run in full-screen and landscape mode.
    *   **Done:** Add a dependency to keep the screen from sleeping.

2.  **UI Development:**
    *   **Done:** Create the main screen of the application.
    *   **Done:** Design and implement a widget for a single time zone clock.
    *   **Done:** Create a mechanism for the user to add, remove, and reorder the clocks.

3.  **State Management:**
    *   **Done:** Use the `provider` package to manage the list of selected time zones and their arrangement on the screen.

4.  **Time Zone Logic:**
    *   **Done:** Integrate the `timezone` package to handle time zone data and calculations.
    *   **Done:** Ensure the clocks update in real-time.
