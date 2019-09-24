# waterishail_share

Share plugin for iOS and Android

## Getting Started

This plugin is used to share images and text via the share API's in android and iOS.

## iOS Configuration
The Info.plist file needs to updated to configure the app to allow access to the photos library

```
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>Your reason for adding photos to the photo library</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Your reason for accessing the photo library</string>
```

## Android Configuration
In order to be able to share a file securely in Android you need to create a file provider in your application

Open the AndroidManifest.xml file and add the following XML to the application element. Remember to change the 
authority to your package name

```
<provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="com.waterishail.waterishail_share_example"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths" />
        </provider>
``` 

Next, create a new folder under the res folder called "xml" and into the "xml" 
folder create a new file called "provider_paths.xml" that will contain the paths to be allowed access by
the FileProvider API sharing. Note that this filename must match the resource attribute in the meta-data element
of the provider element in the AndroidManifest.xml

```
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <root-path name="root" path="/" />
</paths>
```

Here we tell the content provider we want to allow sharing of the file in the application data folder.

 
## Useful links
(Using the share api in iOS)[https://pinkstone.co.uk/how-to-share-things-with-a-uiactivityviewcontroller/]
(Using the share api in Android)[https://medium.com/androiddevelopers/sharing-content-between-android-apps-2e6db9d1368b]