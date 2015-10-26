# Siren

### Notify users when a new version of your app is available, and prompt them with the App Store link.

---
### About
**Siren** checks a user's currently installed version of your iOS app against the version that is currently available in the App Store.

If a new version is available, an alert can be presented to the user informing them of the newer version, and giving them the option to update the application. Alternatively, Siren can notify your app programmatically, enabling you to inform the user through alternative means, such as a custom interface.

- Siren is built to work with the [**Semantic Versioning**](http://semver.org/) system.
	- Semantic Versioning is a three number versioning system (e.g., 1.0.0)
	- Siren also supports two-number versioning (e.g., 1.0)
	- Siren also supports four-number versioning (e.g., 1.0.0.0)
- Siren is a Swift language port of [**Harpy**](http://github.com/ArtSabintsev/Harpy), an Objective-C library that achieves the same functionality.
- Siren is actively maintained by [**Arthur Sabintsev**](http://github.com/ArtSabintsev) and [**Aaron Brager**](http://twitter.com/getaaron).

### Changelog (v0.6.0)
- Dropped iOS 7 support
- Cleaned up codebase

### Changelog (v0.5.1)
- Fixed [#31](https://github.com/ArtSabintsev/Siren/issues/31): `sirenDidShowUpdateDialog()` delegate method now being called properly.

### Changelog (v0.5.0)
- Updated to use Swift 2.0
- Updated for iOS 9
- Closes issues 24/27 (Issue with updaterWindow crashing the app on)
- Closes issue 25 (Issue with alertType not propagating setting to `majorUpdateAlertType`, `minorUpdateAlertType`, `patchUpdateAlertType`, `revisionUpdateAlertType`)
- Closes Issue 26 (Issue with devices running iOS 8+ not storing user's preference to skip current update)

### Features
- [x] CocoaPods Support
- [x] Support for `UIAlertController` (iOS 8+) and `UIAlertView` (iOS 7)
- [x] Localized for 20+ languages (See **Localization** Section)
- [x] Three types of alerts (see **Screenshots & Alert Types**)
- [x] Optional delegate methods (see **Optional Delegate** section)

### Installation Instructions

#### CocoaPods Installation
```ruby
pod 'Siren'
```

- Add `import Siren` to any `.Swift` file that references Siren via a CocoaPods installation.
- Only for apps with a minimum deployment target of iOS 8.0 or later

    > CocoaPods does not support pods written in Swift on iOS 7. For more information, please see [this issue](https://github.com/CocoaPods/swift/issues/22).

If your app needs to support iOS 7, use **Manual Installation**.

#### Manual Installation

1. [Download Siren](//github.com/ArtSabintsev/Siren/archive/master.zip).
2. Copy the `Siren` folder into your project.

### Setup Instructions

Here's some commented sample code. Adapt this to meet your app's needs.

```Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
{
	/* Siren code should go below window?.makeKeyAndVisible() */

	// Siren is a singleton
	let siren = Siren.sharedInstance

	// Required: Your app's iTunes App Store ID
	siren.appID = <#Your_App_ID#>

	// Optional: Defaults to .Option
	siren.alertType = <#SirenAlertType_Enum_Value#>

	/*
	    Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
	    checks.
	*/
    siren.checkVersion(.Immediately)
}

func applicationDidBecomeActive(application: UIApplication)
{
	/*
	    Perform daily (.Daily) or weekly (.Weekly) checks for new version of your app.
	    Useful if user returns to your app from the background after extended period of time.
    	 Place in applicationDidBecomeActive(_:).	*/

    Siren.sharedInstance.checkVersion(.Daily)
}

func applicationWillEnterForeground(application: UIApplication)
{
   /*
	    Useful if user returns to your app from the background after being sent to the
	    App Store, but doesn't update their app before coming back to your app.

       ONLY USE WITH SirenAlertType.Force
   */

    Siren.sharedInstance.checkVersion(.Immediately)
}
```

And you're all set!

### Screenshots & Alert Types

Siren can force an update, let the user optionally update, and allow the user to skip an update.

To control this behavior, assign a `SirenAlertType` to `alertType` (or one of the specific alert type properties).

> #### `siren.alertType = .Force`
>
> Forces the user to update.
>
> ![Forced Update](https://github.com/ArtSabintsev/Harpy/blob/master/samplePictures/picForcedUpdate.png?raw=true "Forced Update")
> ----
> #### `siren.alertType = .Option`
> The default behavior.
>
> ![Optional Update](https://github.com/ArtSabintsev/Harpy/blob/master/samplePictures/picOptionalUpdate.png?raw=true "Optional Update")
> ----
> #### `siren.alertType = .Skip`
> Allows the user to opt out of future reminders for this version.
>
> ![Skip Update](https://github.com/ArtSabintsev/Harpy/blob/master/samplePictures/picSkippedUpdate.png?raw=true "Optional Update")
> ----
> #### `siren.alertType = .None`
>
> This option doesn't show an alert view. It's useful for skipping Revision, Patch, Minor, or Major updates, or for presenting your own UI.

### Prompting for Updates without Alerts

Some developers may want to display a less obtrusive custom interface, like a banner or small icon. To accomplish this, you can disable alert presentation by doing the following:

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
{
	...
	siren.delegate = self
	siren.alertType = .None
	...
}

extension AppDelegate: SirenDelegate
{
	// Returns a localized message to this delegate method upon performing a successful version check
    func sirenDidDetectNewVersionWithoutAlert(message: String) {
        println("\(message)")
    }
}
```

Siren will call the `sirenDidDetectNewVersionWithoutAlert(message: String)` delegate method, passing a localized, suggested update string suitable for display. Implement this method to display your own messaging, optionally using `message`.

### Differentiated Alerts for Revision, Patch, Minor, and Major Updates
If you would like to set a different type of alert for revision, patch, minor, and/or major updates, simply add one or all of the following *optional* lines to your setup *before* calling the `checkVersion()` method:

```swift
	/* Siren defaults to SirenAlertType.Option for all updates */
	siren.sharedInstance().revisionUpdateAlertType = <#SirenAlertType_Enum_Value#>
	siren.sharedInstance().patchUpdateAlertType = <#SirenAlertType_Enum_Value#>
	siren.sharedInstance().minorUpdateAlertType = <#SirenAlertType_Enum_Value#>
	siren.sharedInstance().majorUpdateAlertType = <#SirenAlertType_Enum_Value#>
```

### Optional Delegate and Delegate Methods
Five delegate methods allow you to handle or track the user's behavior:

```	swift
@objc protocol SirenDelegate {
    optional func sirenDidShowUpdateDialog() // User presented with update dialog
    optional func sirenUserDidLaunchAppStore() // User did click on button that launched App Store.app
    optional func sirenUserDidSkipVersion() // User did click on button that skips version update
    optional func sirenUserDidCancel()  // User did click on button that cancels update dialog
    optional func sirenDidDetectNewVersionWithoutAlert(message: String) // Siren performed version check and did not display alert
}
```

### Force Localization
Harpy is localized for Arabic, Basque, Chinese (Simplified), Chinese (Traditional), Danish, Dutch, English, Estonian, French, German, Hebrew, Hungarian, Italian, Japanese, Korean, Latvian, Lithuanian, Polish, Portuguese (Brazil), Portuguese (Portugal), Russian, Slovenian, Swedish, Spanish, Thai, and Turkish.

You may want the update dialog to *always* appear in a certain language, ignoring iOS's language setting (e.g. apps released in a specific country).

You can enable it like this:

```swift
Siren.sharedInstance.forceLanguageLocalization = SirenLanguageType.<#SirenLanguageType_Enum_Value#>
```
### Testing Siren
Temporarily change the version string in Xcode (within the `.xcodeproj`) to an older version than the one that's currently available in the App Store. Afterwards, build and run your app, and you should see the alert.

If you currently don't have an app in the store, use the **AppID** for the iTunes Connect App (*376771144*), or any other app, and temporarily change the version string in `.xcodeproj` to an older version than the one that's currently available in the App Store.

For your convenience, you may turn on `printn()` debugging statements by setting `self.debugEnabled = true` before calling the `checkVersion()` method.

### App Store Submissions
The App Store reviewer will **not** see the alert. The version in the App Store will always be older than the version being reviewed.

### Created and maintained by
[Arthur Ariel Sabintsev](http://www.sabintsev.com/) & [Aaron Brager](http://twitter.com/getaaron)
