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
            let coverImageData = editCoverImage.currentImage?.jpegData(compressionQuality: 1.0),
        let firstname = editFirstNameTF.text, let lastname = editLastName.text,
        let username = editUsername.text, let bio = editBio.text,
        let linkedin = editLinkedin.text , let github = editGithub.text,
            let updateBlogger = blogger, blogger != nil else  {
                print("error with the text fields")
                return
        }
        var photoUrl = ""
        var coverUrl = ""
        StorageService.postImage(imageData: imageData, imageName: "\(BloggersCollectionKeys.PhotoURLKey)/\(updateBlogger.bloggerId)") { [weak self] (error, imageURL) in
            if let error = error {
                self?.showAlert(title: "error", message: error.localizedDescription, actionTitle: "OK")
            } else {
                photoUrl = imageURL?.absoluteString ?? ""
                DBService.firestoreDB
                .collection(BloggersCollectionKeys.CollectionKey)
                .document(updateBlogger.bloggerId)
                .updateData([BloggersCollectionKeys.PhotoURLKey : photoUrl])
        }
            StorageService.postImage(imageData: coverImageData, imageName: "\(BloggersCollectionKeys.CoverImageURLKey)/\(updateBlogger.bloggerId)") { [weak self](error, coverURL) in
                    if let error = error {
                        self?.showAlert(title: "error", message: error.localizedDescription, actionTitle: "OK")
                    } else {
                        coverUrl = coverURL?.absoluteString ?? ""
                        DBService.firestoreDB
                            .collection(BloggersCollectionKeys.CollectionKey)
                            .document(updateBlogger.bloggerId)
                            .updateData([BloggersCollectionKeys.CoverImageURLKey : coverUrl])
                }
            }
            DBService.firestoreDB
                .collection(BloggersCollectionKeys.CollectionKey)
                .document(updateBlogger.bloggerId)
                .updateData([
                              BloggersCollectionKeys.FirstNameKey : firstname,
                              BloggersCollectionKeys.LastNameKey : lastname,
                              BloggersCollectionKeys.BioKey : bio,
                              BloggersCollectionKeys.DisplayNameKey : username,
                              BloggersCollectionKeys.GithubKey : github,
                              BloggersCollectionKeys.LinkedInKey : linkedin,
                              ], completion: { (error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    self?.showAlert(title: "Profile updated", message: nil, actionTitle: "OK")
                                }
                })
        }
          performSegue(withIdentifier: "from edit to profile VC", sender: self)
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
