import UIKit

public struct Configuration {

  // MARK: Colors

  public static var backgroundColor = UIColor(red:0.15, green:0.19, blue:0.24, alpha:1)
  public static var mainColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)
  public static var noImagesColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1)
  public static var noCameraColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1)
  public static var settingsColor = UIColor.whiteColor()

  // MARK: Fonts

  public static var numberLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 19)!
  public static var doneButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
  public static var flashButton = UIFont(name: "HelveticaNeue-Medium", size: 12)!
  public static var noImagesFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public static var noCameraFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public static var settingsFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!

  // MARK: Titles

  public static var cancelButtonTitle = "Cancel"
  public static var doneButtonTitle = "Done"
  public static var noImagesTitle = "No images available"
  public static var noCameraTitle = "Camera is not available"
  public static var settingsTitle = "Settings"

  // MARK: Dimensions

  public static var cellSpacing: CGFloat = 2
    
  // MARK: Custom behaviour
  
  public static var canRotateCamera: Bool = true
  public static var collapseCollectionViewWhileShot: Bool = true
  public static var recordLocation: Bool = true
}
