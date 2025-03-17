//
//  ViewController.swift
//  Example
//
//  Created by Mitu Ultra on 14/3/25.
//

import MiTuKit

class ViewController: UIViewController {

    //Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
    }

}

extension ViewController {
    func setupView() {
        view.backgroundColor = .random
    }
}
