# AnotherRunner

Open-source pedometer and run tracker application.

## Firebase Configuration

This project uses Firebase for authentication and database.

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable the authentication providers: Google and Email/Password.
3. Enable Cloud Firestore.
4. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).
5. At the root of the project, run: `flutterfire configure`

## Google Maps Configuration

For security reasons, the Maps API key is not included in this repository.

1. Generate an API Key in the [Google Cloud Console](https://console.cloud.google.com/) with Maps SDK for Android enabled.
2. Open the file `android/local.properties`.
3. Add the following line at the end of the file:
   `MAPS_API_KEY=YOUR_API_KEY_HERE`