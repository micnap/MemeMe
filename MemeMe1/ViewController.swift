//
//  ViewController.swift
//  MemeMe1
//
//  Created by Michelle Williamson on 9/9/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIButton!
    
    let topDefaultText = "TOP"
    let bottomDefaultText = "BOTTOM"
    
    // Styling attributes of the Meme text
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -4
    ]
    
    // Initial configuration for the fields.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure textfields.
        let textFields = [topText: topDefaultText, bottomText: bottomDefaultText]
        for (textField, defaultText) in textFields {
            setupTextField(textField: textField!, text: defaultText)
        }
    
        shareButton.isEnabled = false
    }
    
    // Utility function for setting up textFIeld configuration.
    func setupTextField(textField: UITextField, text: String) {
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }
    
    // Check if a camera is available on the device.  If not, disable the camera button.
    // Subscribe to keyboard notifications.
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    // Unsubscribe from keyboard notifications.
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }

    // Pick an image from the image library.
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(source: .photoLibrary)
    }
    
    // Take a picture with the camera.
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(source: .camera)
    }
    
    // Utility function for choosing an image from the library or camera.
    func pickAnImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate function.  Callback for when an image is chosen.
    // Grabs the chosen image and enables the share button.
    // https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate function.  Callback for when the action is canceled.
    // Dismisses the activity.
    // https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // UITextFieldDelegate method.
    // Clears the default text in the textfield for editing.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == topDefaultText || textField.text == bottomDefaultText) {
            textField.text = ""
        }
    }
    
    // Close the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Adjust the screen for when the keyboard shows.
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing, view.frame.origin.y == 0 {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // Move the screen back to its original position after editing.
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    // Utility function for accomodating keybaord.
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Add observers for the keyboard notifications.
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Remove all observers for keyboard notifications.
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Save the meme to the photo libary.
    func save() {
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, origImage: imageView.image!, memeImage: generateMemedImage())
    }
    
    // Create the meme so it can be shared and saved.
    func generateMemedImage() -> UIImage {
        
        let fields = [toolbar, shareButton]
        
        // Hide the toolbar and share button so it's not saved in the Meme image.
        for field in fields  {
            toggleDisplay(uiview: field!, hide: true)
        }

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show the fields again.
        for field in fields {
            toggleDisplay(uiview: field!, hide: false)
        }

        return memedImage
    }
    
    // Utility function for hiding/showing fields.
    func toggleDisplay(uiview: UIView, hide: Bool) {
        uiview.isHidden = hide
    }
    
    // Show the built-in iOS activity for sharing media.
    @IBAction func share() {
        // Generate the meme.
        let memedImage: UIImage = generateMemedImage()
        
        // Show the share activity.
        let activityVC = UIActivityViewController.init(activityItems: [memedImage], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
        
        // Set callback for when activity returns from sharing media.  Save the meme to the library.
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                return
            } else {
                print("cancel")
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
    }
}

