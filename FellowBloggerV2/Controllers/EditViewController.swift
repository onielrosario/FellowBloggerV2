//
//  EditViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/15/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Firebase
import Toucan

enum ProfilePhotos {
    case profileImage
    case coverImage
}

enum CurrentProfileStatus {
    case newAccount
    case currentUser
}

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editProfileButton: CircularButton!
    @IBOutlet weak var editCoverImage: UIImageView!
    private var coverTap: UITapGestureRecognizer!
    var user: Blogger!
    private var bloggerProfileImage: CircularButton!
    private var bloggerCoverImage: UIImageView!
    var firstName = ""
    var lastName = ""
    var userName = ""
    var bloggerBio = ""
    public var bloggerInfo = [String]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    public var editTextFields = [String]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    private var editProfilePhoto: ProfilePhotos?
    private var editLabels: [String] = ["First Name","Last Name","Username", "Edit Bio    "]
    var tap: UITapGestureRecognizer!
    var bio = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var authservice = AppDelegate.authService
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
          getMyInfo()
               configureTableview()
        } else {
        configureTableview()
        updateUI()
        }
    }
    
    private func getMyInfo() {
                self.firstName = user.firstName ?? ""
                self.lastName = user.lastName ?? ""
                self.userName = user.displayName
                self.bloggerBio = user.bio ?? ""
                self.editProfileButton.kf.setImage(with: URL(string: user.photoURL ?? ""), for: .normal, placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
                self.editCoverImage.kf.setImage(with: URL(string: user.coverImageURL ?? ""), placeholder: #imageLiteral(resourceName: "tealCover.jpg"))
            }
    
    private func  updateUI() {
        coverTap = UITapGestureRecognizer(target: self, action: #selector(coverPhotoTapped))
        self.editCoverImage.isUserInteractionEnabled = true
        editCoverImage.addGestureRecognizer(coverTap)
    }
    private func configureTableview() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollsToTop = true
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func profilePhotoPressed(_ sender: CircularButton) {
        editProfilePhoto = ProfilePhotos.profileImage
        presentImagePicker()
    }
    
    
    @objc private func coverPhotoTapped() {
        self.editProfilePhoto = ProfilePhotos.coverImage
        presentImagePicker()
    }
    
    private func pushControllers(controller: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: controller)
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
            guard !self.firstName.isEmpty,
                   !self.lastName.isEmpty,
                !self.userName.isEmpty,
                !self.bloggerBio.isEmpty,
                let user = authservice.getCurrentUser(),
                let imageData = editProfileButton.currentImage?.jpegData(compressionQuality: 1.0),
                let coverImageData = editCoverImage.image?.jpegData(compressionQuality: 1.0) else  {
                    print("error with the text fields")
                    return
            }
            StorageService.postImage(imageData: imageData, imageName: "\(BloggersCollectionKeys.PhotoURLKey)/\(user.uid)") { [weak self] (error, imageURL) in
                StorageService.postImage(imageData: coverImageData, imageName: "\(BloggersCollectionKeys.CoverImageURLKey)/\(user.uid)") { [weak self](error, coverURL) in
                    let request = user.createProfileChangeRequest()
                    request.photoURL = imageURL
                    request.displayName = self?.userName
                    request.commitChanges(completion: { (error) in
                        if let error = error {
                            self?.showAlert(title: "error", message: error.localizedDescription, actionTitle: "OK")
                        }
                    })
                    DBService.firestoreDB
                        .collection(BloggersCollectionKeys.CollectionKey)
                        .document(user.uid)
                        .updateData([BloggersCollectionKeys.DisplayNameKey : self!.userName,
                                     BloggersCollectionKeys.CoverImageURLKey: coverURL?.absoluteString ?? "",
                                     BloggersCollectionKeys.PhotoURLKey: imageURL?.absoluteString ?? "",
                                     BloggersCollectionKeys.FirstNameKey: self!.firstName,
                                     BloggersCollectionKeys.LastNameKey: self!.lastName,
                                     BloggersCollectionKeys.BioKey: self!.bloggerBio
                            ], completion: { (error) in
                                if let error = error {
                                    self?.showAlert(title: "error saving account info", message: error.localizedDescription, actionTitle: "try again")
                                }
                        })
                }
            }
        
        performSegue(withIdentifier: "from edit to profile VC", sender: self)
    }
    
    private func presentImagePicker() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func unwindFromEditBioVontroller(segue: UIStoryboardSegue) {
        let editBioVC = segue.source as! EditBioViewController
        self.bio = editBioVC.editBioTextView.text
    }
}

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editLabels.count
    }
    @objc private func textFieldTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editBioVC = storyboard.instantiateViewController(withIdentifier: "EditBioVC") as! EditBioViewController
        let bio = bloggerInfo.last ?? ""
        editBioVC.bio = bio
    navigationController?.pushViewController(editBioVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BioCell", for: indexPath) as? BioCell else { return UITableViewCell() }
            tap = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
            if user != nil {
                let editLabel = editLabels[indexPath.row]
                cell.bioCellLabel.text = editLabel
                let info = bloggerInfo[indexPath.row]
                 cell.bioTextField.addGestureRecognizer(tap)
                cell.bioTextField.text = info
            } else {
                let editLabel = editLabels[indexPath.row]
                cell.bioCellLabel.text = editLabel
                cell.bioTextField.addGestureRecognizer(tap)
                cell.bioTextField.text = bio
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as? EditCell else {
                return UITableViewCell()
            }
            if user != nil {
                let info = bloggerInfo[indexPath.row]
                cell.editTextField.text = info
            }
            let labelTitle = editLabels[indexPath.row]
            cell.editLabel.text = labelTitle
            if user != nil {
                let info = bloggerInfo[indexPath.row]
                cell.editTextField.text = info
            }
            cell.editTextField.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editBioVC = storyboard.instantiateViewController(withIdentifier: "EditBioVC") as! EditBioViewController
            let bio = editLabels[indexPath.row]
             editBioVC.bio = bio
            navigationController?.pushViewController(editBioVC, animated: true)
        }
    }
}

extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 90
        } else {
            return 50
        }
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            guard !text.isEmpty else {
                return false
            }
        }
        return true
    }
}

extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  else {
            print("original image not available")
            return
        }
        let size = CGSize(width: 500, height: 350)
        let resizedImage = Toucan.Resize.resizeImage(originalImage, size: size)
        if editProfilePhoto == .coverImage {
            self.editCoverImage.image = resizedImage
        } else {
            self.editProfileButton.setImage(resizedImage, for: .normal)
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
