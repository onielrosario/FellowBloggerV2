//
//  RefatorEditProfileTableViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/21/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Firebase
import Toucan
import Kingfisher

enum ProfilePhotos {
    case profileImage
    case coverImage
}

class RefatorEditProfileTableViewController: UITableViewController {
    @IBOutlet weak var editCoverImage: UIButton!
    @IBOutlet weak var editProfileImage: CircularButton!
    @IBOutlet weak var editFirstNameTF: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editUsername: UITextField!
    @IBOutlet weak var editGithub: UITextField!
    @IBOutlet weak var editLinkedin: UITextField!
    @IBOutlet weak var editBio: UITextView!
    var blogger: Blogger!
    private lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    private var editProfilePhoto: ProfilePhotos?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    private func updateUI () {
        tableView.tableFooterView = UIView()
        editCoverImage.kf.setImage(with: URL(string: blogger.coverImageURL ?? ""), for: .normal)
       editProfileImage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), for: .normal)
        editFirstNameTF.text = blogger.firstName
        editLastName.text = blogger.lastName
        editUsername.text = blogger.displayName
        editGithub.text = blogger.github ?? ""
        editLinkedin.text = blogger.linkedIn ?? ""
        editBio.text = blogger.bio
    }
    
    @IBAction func coverImage(_ sender: UIButton) {
        editProfilePhoto = ProfilePhotos.coverImage
    }
    @IBAction func profileImagePressed(_ sender: CircularButton) {
        editProfilePhoto = ProfilePhotos.profileImage
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        guard let imageData = editProfileImage.currentImage?.jpegData(compressionQuality: 1.0),
            let coverImageData = editCoverImage.currentImage?.jpegData(compressionQuality: 1.0) else  {
                print("error with the text fields")
                return
        }
        StorageService.postImage(imageData: imageData, imageName: "\(BloggersCollectionKeys.PhotoURLKey)/\(self.blogger.bloggerId)") { [weak self] (error, imageURL) in
            StorageService.postImage(imageData: coverImageData, imageName: "\(BloggersCollectionKeys.CoverImageURLKey)/\(self!.blogger.bloggerId)") { [weak self](error, coverURL) in
                let user = AppDelegate.authService.getCurrentUser()
                let request = user?.createProfileChangeRequest()
                request!.photoURL = imageURL
                request!.displayName = self?.editUsername.text ?? ""
                request!.commitChanges(completion: { (error) in
                    if let error = error {
                        self?.showAlert(title: "error", message: error.localizedDescription, actionTitle: "OK")
                    }
                })
                DBService.firestoreDB
                    .collection(BloggersCollectionKeys.BloggerIdKey)
                    .document(BloggersCollectionKeys.BloggerIdKey)
                    .updateData([ BloggersCollectionKeys.CoverImageURLKey : self!.blogger.coverImageURL ?? "",
                                  BloggersCollectionKeys.PhotoURLKey : self!.blogger.coverImageURL ?? "",
                                  BloggersCollectionKeys.FirstNameKey : self!.blogger.firstName ?? "",
                                  BloggersCollectionKeys.LastNameKey : self!.blogger.lastName ?? "",
                                  BloggersCollectionKeys.DisplayNameKey : self!.blogger.displayName ,
                                  BloggersCollectionKeys.BioKey : self!.blogger.bio ?? "",
                                  BloggersCollectionKeys.GithubKey : self!.blogger.github ?? "",
                                  BloggersCollectionKeys.LinkedInKey : self!.blogger.linkedIn ?? "",
                                  ], completion: { (error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    self?.showAlert(title: nil, message: "profile updated", actionTitle: "OK")
                    })
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RefatorEditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  else {
            print("original image not available")
            return
        }
        let size = CGSize(width: 500, height: 350)
        let resizedImage = Toucan.Resize.resizeImage(originalImage, size: size)
        if editProfilePhoto == .coverImage {
            self.editCoverImage.setImage(resizedImage, for: .normal)
        } else {
            self.editProfileImage.setImage(resizedImage, for: .normal)
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
