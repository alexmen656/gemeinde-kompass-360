# Gemeinde Kompass 360

Gemeinde Kompass 360 is an iOS application that helps users explore municipalities, counties, and federal states in Austria. The app provides detailed information about each region, including descriptions, images, and geographical data.

## Features

- **Home View**: Discover various municipalities in Austria with detailed information and images.
- **Federal States View**: View a map of Austria's federal states with interactive overlays.
- **Favorites**: Save your favorite municipalities for quick access.
- **Settings**: Customize your app experience.

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/alexmen656/gemeinde-kompass-360.git
    ```
2. Open the project in Xcode:
    ```sh
    cd gemeinde-kompass-360
    open gemeinde-kompass-360.xcodeproj
    ```
3. Build and run the project on your simulator or device.

## Usage

### Home View

The Home view displays a list of municipalities. You can filter the list by federal state and district using the filter button. Each municipality is displayed with its name, description, and an image.

### Federal States View

The Federal States view shows a map of Austria with overlays for each federal state. You can tap on a state to see more details.

### Favorites

Save your favorite municipalities by tapping the heart icon. Access them quickly from the Favorites tab.

### Settings

Customize your app experience in the Settings view.

## API

The app fetches data from a backend API. The API endpoints are defined in the `api` directory. Here are some key endpoints:

- **Get all federal states**: `?action=all`
- **Get counties by federal state**: `?action=counties&federal_state={federal_state_id_or_name}`
- **Get municipalities by county**: `?action=municipalities&county={county_id_or_name}`

## Contact

For any questions or feedback, please contact Slack.
