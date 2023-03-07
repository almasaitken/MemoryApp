//
//  DetailViewController.swift
//  Day50_Milestone
//
//  Created by Almas Aitken on 31.01.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var memory: Memory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
    
        if let memory = memory {
            title = memory.imageCaption
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let imagePath = documentPath.appendingPathComponent(memory.imageName)
            
            imageView.image = UIImage(contentsOfFile: imagePath.path)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
