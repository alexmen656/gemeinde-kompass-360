# Gemeinde Kompass 360

Gemeinde Kompass 360 is an iOS application that helps users explore municipalities, counties, and federal states in Austria. The app provides detailed information about each region, including descriptions, images, and geographical data.

## Features
- **MapKit Integration**: Show municipality locations on a map.
- **Custom API**: Built with web scrapers to fetch data.
- **Apple WeatherKit Integration**: Display current weather for municipalities (currently disabled due to lack of paid Apple Developer account).
- **PredictHQ API**: Fetch and display events.
- **Image Integration**: Each municipality has an image and a coat of arms.
- **Comprehensive Statistics and Info**: Includes postal code, population, area, mayor, and more.
- **Filter**: Filter municipalities by federal state and/or district.
- **Multi-language Support**: The app supports both English and German languages. - Doesn't work properly in this moment.

## APP
- **Home View**: Discover various municipalities in Austria with detailed information and images.
- **Federal States View**: View a map of Austria's federal states with interactive overlays.
- **Favorites**: Save your favorite municipalities for quick access.
- **Settings**: Customize your app experience.

## Demo
[Video Demo - YouTube](https://youtu.be/mdxdGV-9WSs)

## Usage (How to use)

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

## Screenshots
| ![Screenshot1](screenshots/1.PNG) | ![Screenshot2](screenshots/2.PNG) | ![Screenshot3](screenshots/3.PNG) |
|---|---|---|
| ![Screenshot4](screenshots/4.PNG) | ![Screenshot5](screenshots/4e.PNG) | ![Screenshot6](screenshots/5.PNG) |
|---|---|---|
| ![Screenshot7](screenshots/6.PNG) | ![Screenshot8](screenshots/7.PNG) | ![Screenshot9](screenshots/8.PNG) |
|---|---|---|
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

   
## Contact

For any questions or feedback, please contact Slack.
