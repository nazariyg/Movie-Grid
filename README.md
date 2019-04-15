# Movie Grid

**Movie Grid** is to represent my vision for a modern, modular, and testable iOS app with a clean architecture.

To do a fair job of it, the repository includes a significant portion of my own code base that I've authored over time. This enabled me to demonstrate what my own rendition of a Movie Database app would look like, using the designs provided in the task. The code base used by the app is my open source project I currently maintain at<br/>
https://github.com/nazariyg/Swift-App-Core

Hopefully, the points of interest given below will be helpful in navigating through what's most definitive about the app's architecture and its business logic.

## Requirements

Xcode 10.2 with Swift 5.

## Points of interest

* The app is comprised of three modules: the fundamental Cornerstones module, the Core module containing code to be shared by other modules should the app ever grow larger, and the main MovieGrid module. Besides of the benefits of the modularity principle, this approach to app structuring significantly reduces build times when developing a potentially large project in Swift, which doesn't compile as snappy as Objective-C.
* In the Core module you can find the app's configuration, core UI, networking layer, the scheme for the Movie Database API, data entities e.g. `APIMovie`, the Movie Database API requesting service, and others. The Cornerstones module contains extensions to Swift, Foundation, and UIKit, concurrency utilities, the basics of the networking layer, testing utilities, and others.
* `Core/Configuration` contains the configuration for the Movie Database API's backend.
* `Core/BackendAPI/Backend` contains the code outlining the structural schema of the Movie Database API as e.g. `Backend.API.Movie.nowPlaying` API endpoint, lets parse the specific date formats returned by the backend, and let construct and send HTTP requests tailored for the backend.
* The app overall and its architecture take advantage of functional-reactive programming approaches by using ReactiveSwift/ReactiveCocoa. The app's components wire in events/requests from other components in order to get notified when they deem appropriate. Time consuming operations such as making network requests are wrapped into cold signals (`SignalProducer`) to be observed for events after the signal is told to start.
* `Core/Entities` contains the backend API and persistent store entities used by the app.
* The Core's `MovieDatabaseService` is using backend endpoints e.g. `nowPlaying` for sending requests to the Movie Database API and deserializes JSON responses into API entities e.g. `APIMoviesPage`. The JSON deserialization takes place on a background queue.
* The Core's `NowPlayingMoviesProvider` is in turn using `MovieDatabaseService` to make API requests and construct persistent store entities e.g. `Movie` from received API entities. `NowPlayingMoviesProvider` is then adding received movies to the default store, which is based on Realm, and is using the store as the single source of truth to update the complete list of loaded movies. Movies are processed on a background queue.
* The app is using a version of the VIPER architecture in which VIPER components are communicating with one another in a functional-reactive way my means of events and requests, e.g. the view is listening on and reacts upon the presenter's requests, the interactor is listening on the presenter's events, and so forth. This is beneficial by keeping out needlessly repeating code from VIPER protocols and methods while the roles of VIPER components remain the same as in the regular VIPER. The view is observing on the main queue, while the interactor and the presenter are observing on a background queue. The local router invokes the global router upon events that should lead to a screen transition. I only prefer using this boilerplate-free version of VIPER for my own projects.
* The home screen's interactor constructs an instance of `NowPlayingMoviesProvider` and uses it to start loading/reloading movies and it gets notified every time the movie list is updated. If currently offline or movie reloading fails, it tells the movie provider to load movies from the persistent store. Loaded movies are passed down to the presenter, which constructs corresponding view models and passes them to the view. Movie model entities never cross the boundary between interactor/presenter that operate on a background queue and the view operating on the main queue.
* Because I've been long favoring laying out UI in code instead of storyboards, the app is using my own solution for adjusting point values for UI element dimensions, distances, and font sizes depending on the size and PPI of the current iPhone's screen, automatically resulting in smaller point values for smaller screens e.g. iPhone SE and higher point values for bigger screens e.g. iPhone Xs Max, which is the desired effect in most cases. More on this and on the `s()`/`screenify()` function can be found in `Cornerstones/UIKit/UIScreen/UIScreenMetrics.swift`. My preferred syntactic engine for autolayout is [Cartography](https://github.com/robb/Cartography).
* The initial VIPER scene is provided by `InitialSceneProvider`. The app manages the screen stack and screen transitions using `UIScener` and `UIGlobalSceneRouter`. Screen transition animations are my custom ones.
* For the purposes of testing, the app's architecture supports dependency injection for private and shared object instances using `InstanceProvider`: when asked for an instance that should conform to a given protocol, `InstanceProvider` returns the currently set such instance under tests or returns the default instance under normal execution. `InstanceProvider` also supports dependency injection for HTTP network responses.

## Task implementation notes

* The app supports browsing previously retrieved movies without Internet connection as well as opening movie details while offline.
* Supports pull to refresh.
* Has custom Lottie animation for the loading indicator.
* When changing orientation while at the movie browser screen, the collection view sticks to displaying roughly the same movies as before the orientation change.
* The app's code style is overseen by my own SwiftLint configuration with my custom value for the maximum line length and custom rule exceptions.
* Although one of the design images shows a "Load more" button presumably at the end of a page on the browser screen, the upfollowing text however specifies the requirement as "load an initial set of movie data for 20 movies, display those in a grid and when the user scrolls down you should progressively load another set of 20 movies". It was chosen to load movie pages dynamically as the user scrolls down the list.
* The Movie Database API currently does not seem to provide any movie rating classification, e.g. "R" or "PG", therefore the movie detail screen omits this info.
* On the app's movie detail screen, the movie's title doesn't include the year of release since this info is already present in the "Release date" on the same screen.
