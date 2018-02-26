//
//  ChangeCityViewController.swift
//  ClimaApp
//
//  Created by Luana on 26/02/18.
//  Copyright © 2018 lccj. All rights reserved.
//


import UIKit

class ChangeCityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var changeCityTextField: UITextField!
    
    // MARK: - Instance Variables
    var delegate : ChangeCityDelegate?
    
    // MARK: - ViewCicle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Actions
    @IBAction func getWeatherButton(_ sender: UIButton) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

