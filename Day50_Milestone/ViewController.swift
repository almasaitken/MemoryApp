//
//  ViewController.swift
//  Day50_Milestone
//
//  Created by Almas Aitken on 31.01.2023.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var memories = [Memory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory Storage"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        let defaults = UserDefaults.standard
        
        DispatchQueue.global().async {
            [weak self] in
            if let data = defaults.data(forKey: "memories") {
                do {
                    self?.memories = try JSONDecoder().decode([Memory].self, from: data)
                } catch {
                    print("Failed to load memories.")
                }
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
                
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memory = memories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Memory", for: indexPath)
        
        if let cell = cell as? MemoryCell {
            let imagePath = getDocumentsDirectory().appendingPathComponent(memory.imageName) 
            cell.memoryLabel.text = memory.imageCaption
            cell.memoryView.image = UIImage(contentsOfFile: imagePath.path)
            cell.memoryView.layer.cornerRadius = 6
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.memory = memories[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    @objc func addButtonTapped() {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        DispatchQueue.global().async {
            [weak self] in
            let imageName = UUID().uuidString
            let imagePath = self?.getDocumentsDirectory().appendingPathComponent(imageName)
            
            if let jpegData = image.jpegData(compressionQuality: 0.8), let imagePath = imagePath {
                try? jpegData.write(to: imagePath)
            }

            DispatchQueue.main.async {
                [weak self] in
                self?.dismiss(animated: true)

                self?.showCaptionAlert(imageName: imageName)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func showCaptionAlert(imageName: String) {
        let ac = UIAlertController(title: "Add caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            guard let caption = ac?.textFields?[0].text else { return }
            let memory = Memory(imageName: imageName, imageCaption: caption)
            self?.memories.append(memory)
            self?.saveMemories()
        })
        present(ac, animated: true)
    }
    
    func saveMemories() {
        DispatchQueue.global().async {
            [weak self] in
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(self?.memories) {
                defaults.set(jsonData, forKey: "memories")
            }
            
            DispatchQueue.main.async {
                [weak self] in
                self?.tableView.reloadData()
            }
            
        }
    }
    
}

