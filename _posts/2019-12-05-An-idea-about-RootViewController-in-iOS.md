---
layout: post
title: An idea about RootViewController in iOS
date: 2019-12-05 19:21:00
comment_id: 32
categories: [iOS, Swift]
tags: [AppDelegate]
---

If you are an iOS engineer, then you must be familiar with `AppDelegate`.

If you have experience to write a custom rootViewController(which means not directly use the Xcode provided `Sample Single View App`, instead, you chanage its root, and add your customize rootViewController). Then you must already know `window.rootViewController`.

For more, your app might also require you to `change the rootViewController` for some cases. And, here it is, our today's topic, do we have other way to implement it instead of change the `window.rootViewController`?

Most of app might require user to login. And for supporting login, user need to:

- Login the app
- (Some app might also show the Update Page for version Update)Optional
- After Login, show the Main Screen
- In some parts of Main Screen, user should be allowed to Logout the app

Previously our app not require login at the beginning, so even we add the login logic in some other page. It does not have so much influence on the rootViewController. Although we have a update page, we just change the `window.rootViewController` directly. Though we only change this rootViewController only at the `AppDelegate` part, but we still kind of worry it.

So, by this chance, we want to update this logic here.

## Idea

### Transitions

Imagine we will have these pages:

- Launcher
- Splash
- Login <- Authenticate part
- MainTab <- which will be the main page of the app, it contains 2 tabs:
    - First page
    - Logout

Before starting, we should check which transitions we need to add:

1. Splash -> Authentication(Login)
2. Splash -> Main: User already login, redirect it to MainTab page
3. Main -> Authentication: User logout, session expired
4. Deeplink (Optional) (In this part, we will skip it)

### RootViewController

For adding these transitions, we prepare to use `one` `RootViewController` to handle it. The structure of this `RootViewController` would be:

```swift
RootViewController{
    root: UIViewController

    switchToLogin() // <- case 1, 3
    switchToMain() // <- case 2
}
```

## Code

### AppDelegate

Go back to show the coding part. By using this idea, inside the `AppDelegate.application(_ application:, didFinishLaunchingWithOptions:)` part, we could simply keep `window.rootViewController = RootViewController()`, like this: ⬇️

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    let rootVC = RootViewController()
    window?.rootViewController = rootVC
    window?.makeKeyAndVisible()

    return true
}
```

For simply using this rootViewController in later code, we could set its `share.rootViewController` property:

```swift
extension AppDelegate {
    static var shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var rootViewController: RootViewController {
        return window?.rootViewController as! RootViewController
    }
}
```

### SplashViewController

Add an `activityIndicator` on it for simulating splash screen loading server API:

```swift
class SplashViewController: UIViewController {
     private let activityIndicator = UIActivityIndicatorView()

     override func viewDidLoad() {
          super.viewDidLoad()

          view.backgroundColor = .white

          view.addSubview(activityIndicator)
          activityIndicator.frame = view.bounds
          activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.5)

          preloadServerAPI()
     }
}
```

Use `DispatchQueue` to mock api request timing, and temporary use `UserDefaults.standard` for checking status:

```swift
private func preloadServerAPI() {
    // mock server api connect
    activityIndicator.startAnimating()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
        print("[API] Server API Preloaded")
        self?.activityIndicator.stopAnimating()

        // temporary use UserDefaults for checking status
        if UserDefaults.standard.bool(forKey: "He-Wu.RootViewControllerNavigation.login") {
            // navigate to main page
            AppDelegate.shared.rootViewController.switchToMain()
        } else {
            // navigate to login page
            AppDelegate.shared.rootViewController.switchToLogin()
        }
    }
}
```

### Login & Logout

Simple set it by adding a label & login/logout button. We do this setup at the xib file, the image would be like this:

![login](/images/2019-12-05-An-idea-about-RootViewController-in-iOS/login.png#simulator)
![logout](/images/2019-12-05-An-idea-about-RootViewController-in-iOS/logout.png#simulator)

For button tap action, set it as:

```swift
// tap login button
@IBAction func tapLoginButton(_ sender: Any) {
    UserDefaults.standard.set(true, forKey: "He-Wu.RootViewControllerNavigation.login")
    print("[Authentication] Login Successfully")
    AppDelegate.shared.rootViewController.switchToMain() // redirect to main page
}

// tap logout button
@IBAction func tapLogoutButton(_ sender: Any) {
    // temporary mock logout actions
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
        print("Logout Successfully")
        UserDefaults.standard.set(false, forKey: "He-Wu.RootViewControllerNavigation.login")
        AppDelegate.shared.rootViewController.switchToLogin() // logout, redirect to login page
    }
}
```

### MainTab & First

We could simply set the FirstViewController only contains a label for describing its name, like this:
![first](/images/2019-12-05-An-idea-about-RootViewController-in-iOS/first.png#simulator)

Then, for the Main page(MainTab) part, set its viewControllers as `[first, logout]`:

```swift
class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstVC = FirstViewController()
        firstVC.title = "First View Controller"

        let logoutVC = LogoutViewController()
        logoutVC.title = "Logout View Controller"

        var viewControllers = [UIViewController]()
        for viewController in [firstVC, logoutVC] {
            viewControllers.append(UINavigationController(rootViewController: viewController))
        }
        setViewControllers(viewControllers, animated: false)
    }
}
```

### RootViewController

At the end, we set our `RootViewController`, first should be the init part, we set its original root as Splash page:

```swift
final class RootViewController: UIViewController {

    private var root: UIViewController

    init() {
        root = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        addChild(root)
        root.view.frame = view.bounds
        view.addSubview(root.view)
        root.didMove(toParent: self)
    }
}
```

For `switch` part, we could just replace our `RootViewController.root` & udpate its child would be enough:

```swift
func switchToLogin() {
    let loginVC = LoginViewController()

    addChild(loginVC)
    loginVC.view.frame = view.bounds
    view.addSubview(loginVC.view)
    loginVC.didMove(toParent: self)

    // remove original one
    root.willMove(toParent: nil)
    root.view.removeFromSuperview()
    root.removeFromParent()

    // replace root with loginVC
    root = loginVC
}

func switchToMain() {
    let mainVC = MainTabBarController()

    addChild(mainVC)
    mainVC.view.frame = view.bounds
    view.addSubview(mainVC.view)
    mainVC.didMove(toParent: self)

    root.willMove(toParent: nil)
    root.view.removeFromSuperview()
    root.removeFromParent()

    root = mainVC
}
```

Until now, all of our logic are added. You could check the result would be like this:
![finishLogic](/images/2019-12-05-An-idea-about-RootViewController-in-iOS/finishLogic.gif#simulator)

## Optional

By using this method, you could simply check your current application root by using `AppDelegate.shared.rootViewController`. And if you want, you could also add more logic on the redirect part. OR you could add any transfer animation at the switch part~ 🎉

#### Project link

<https://github.com/HevaWu/RootViewControllerNavigation>
