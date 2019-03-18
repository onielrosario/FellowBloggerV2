//
//  AddBloggViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/17/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Toucan

class AddBloggViewController: UIViewController {
    @IBOutlet weak var blogDescription: UITextView!
    @IBOutlet weak var newBlogImage: UIImageView!
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    private var selectedImage: UIImage?
    private var authservice = AppDelegate.authService
    override func viewDidLoad() {
        super.viewDidLoad()
    blogDescription.clipsToBounds = true
    blogDescription.layer.cornerRadius = 10
    blogDescription.delegate = self
        configureKeyBoard()
    }
    
    private func configureKeyBoard() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let cameraBarItem = UIBarButtonItem(barButtonSystemItem: .camera,
                                            target: self,
                                            action: #selector(cameraButtonPressed))
        let photoLibraryBarItem = UIBarButtonItem(title: "Photo Library",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(libraryButtonPressed))
        let flexibleBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [cameraBarItem, flexibleBarItem, photoLibraryBarItem]
        blogDescription.inputAccessoryView = toolbar
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraBarItem.isEnabled = false
        }
        
    }
    
    @objc private func cameraButtonPressed() {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    @objc private func libraryButtonPressed() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }

    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
    }
  
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let description = blogDescription.text, !description.isEmpty,
        let imageData = selectedImage?.jpegData(compressionQuality: 1.0) else {
                print("missing fields")
                return
        }
        guard  let user = authservice.getCurrentUser() else {
            print("no logged user")
            return
        }
        let docRef = DBService.firestoreDB
        .collection(BlogsCollectionKeys.CollectionKey)
        .document()
        StorageService.postImage(imageData: imageData, imageName: "blogs/" + "\(user.uid)/\(docRef.documentID)") { [weak self] (error, imageURL) in
            if let error = error {
                print("fail to post image with error: \(error.localizedDescription)")
            } else if let imageURL = imageURL {
                print("image posted and received")
                let blog = Blog(createdDate: Date.getISOTimestamp(), bloggerId: user.uid, imageURL: imageURL.absoluteString, blogDescription: description, documentId: docRef.documentID)
                DBService.postBlog(blog: blog)
            self?.showAlert(title: "success", message: "image posted", actionTitle: "ok")
            }
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension AddBloggViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}

extension AddBloggViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("original image is nil")
            return
        }
        let resizedImage = Toucan.init(image: originalImage).resize(CGSize(width: 500, height: 500))
        selectedImage = resizedImage.image
        newBlogImage.image = resizedImage.image
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
