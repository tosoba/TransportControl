<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
<img src="https://raw.githubusercontent.com/tosoba/TransportControl/master/app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Logo" width="150" height="150">

<h2 align="center">TransportControl</h2>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
    </li>
    <li><a href="#license">License</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<div align="center">
<img src="https://raw.githubusercontent.com/tosoba/TransportControl/master/Screenshot_1.png" alt="Logo" width="270" height="570">
<img src="https://raw.githubusercontent.com/tosoba/TransportControl/master/Screenshot_2.png" alt="Logo" width="270" height="570">
</div>

Places search app with both AR and map views.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started


1. Create a project at [https://console.cloud.google.com/](https://console.cloud.google.com/).
2. Enable Google Maps
3. Paste the API key into `AndroidManifest.xml`
   ```xml
   <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="<GOOGLE_API_KEY>" />
   ```
4. Go to [https://api.um.warszawa.pl/](https://api.um.warszawa.pl/), create an account and a get an API key
5. Paste the API key into `vehicles_api.dart`
   ```dart
   static const key = '<UM_WARSZAWA_API_KEY>';
   ```
<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.md` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

