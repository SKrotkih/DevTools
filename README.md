# DevTools
============

This is a Mac OS X Application for using as a development tools.
It has some features which can be used for debugging, tracing code, creation of UML diagrams and making UI test scripts.

## Implements

- Sending log messages to instrumental OSX-app by network. You needn't connect device for debugging of your application. You can see all logs on the tool-app text view. This tool may be useful for debugging iOS applications in cases when you need disconnect device. For example for connecting the external keyboard.

- On side OSX-tool application, you can see a current UIView hierarchy diagram. This diagram is presented before starting the test and may be presented by pressing a button. On the UIView hierarchy diagram, every UIView may be moved by hand. At the same time, you can see a tree of UIViews and every class description, which you can use for creating UI-tests. You can save the diagram as PDF-file. This possibility may be useful for researching of the UIView hierarchy and bug fixing.

- In this project was used UISpec. UISpec is an open-source project for UI-testing. You can integrate test-scripts to your app. All tests may be writing in Objective-C or in special internal scripts language. All information about test-tracking is sent to the desktop application by network. The advantage of this approach is you can write UI-tests without limitation. Every iOS developer can write UI-tests without study of a new language.

- This tool can generate inheriting and dependencies diagrams. If you select class on tree view you will see inheriting diagram. As an addition, you can see dependencies diagram for the current class. It means classes from which depends on the current class. This tool you can use for development. For example, you want to know affect how changing class interface may affect on its dependencies. Diagram items may by moved by hand. You can save the diagram as PDF-file and so on.

- Runtime browser uses the ability of runtime library for generating lists of classes, methods, etc on run time. This tool allows to generate lists on the client side and on a desktop app side as well. This tool is used for methods call tracking. You can save and then restore lists to file.

- This tool allows to track methods calling. You can track methods only for one class or list classes. You can generate list classes using the Runtime browser as well. This tools can be used for researching class behavior and for debugging.

## Requirements

- Xcode 6
- Mac OS 10.7

## Author

Sergey Krotkih 
- http://stackoverflow.com/users/1709337/stosha
- https://www.linkedin.com/pub/sergey-krotkih/20/6a4/274
- http://sergey-krotkih.blogspot.com

## License

DevTools is available under the MIT license. See the LICENSE file for more info.

## Update
