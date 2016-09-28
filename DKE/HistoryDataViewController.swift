//
//  HistoryDataViewController.swift
//  DKE
//
//  Created by Romain Boudet on 20/09/16.
//  Copyright © 2016 Romain Boudet. All rights reserved.
//

import UIKit

class HistoryDataViewController: UIViewController {

    static var toPass : String?
    var textToShow = ""
    
    @IBOutlet weak var Open: UIBarButtonItem!
    @IBOutlet weak var textBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.revealViewController() != nil){
            
            Open.target = self.revealViewController()
            Open.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        print(HistoryDataViewController.toPass)
        if (HistoryDataViewController.toPass == "objects"){
            textToShow = "The Objects of Delta Kappa Epsilon are : \n\nThe cultivation of general literature and social culture,\n\nThe advancement and encouragement of intellectual excellence,\n\nThe promotion of honorable friendship and useful citizenship,\n\nThe development of a spirit of tolerance and respect for the rights and views of others,\n\nThe maintenance of gentlemantly dignity, self-respect, and morality in all circumstances and,\n\nThe union of stout hearts and kindred interests, to secure to merit its due reward."
            
            textBox.text = textToShow
            textBox.textAlignment = .Center

        }
        else if (HistoryDataViewController.toPass == "DKEFoundingFathers"){
            textToShow = "- William woodruff atwater\n- Edward griffin bartlett\n- Frederic peter bellinger Jr \n- Henry case\n- George foote chester\n- John Butler Conyngham\n- Thomas isaac franklin\n- William walter horton\n- William boyd jacobs\n- Edward vanshoonhoven kinsley\n- Chester newell righter\n- Elisha bacon shapleigh\n- Thomas dubois sherwood\n- Albert everett stetson\n- Orson william stow"
            textBox.text = textToShow
            textBox.textAlignment = .Left
        }
        else if(HistoryDataViewController.toPass == "DKEFirstChapters"){
            textToShow = " 1 : phi yale  1844               \n 2 : theta bowdoin  1844         \n 3 : zeta princeton  1845         \n 4 : xi colby college  1846       \n 5 : sigma anherst  1846         \n 6 : gamma Vanderbilt 1848      \n 7 : psi alabama  1847            \n 8 : chi missisipi  1850\n 9 : upsilon brown 1850\n 10 : beta north carolina  1851\n 11 : alpha Harvard  1851         \n 12 : kappa Miami  1852         \n 13 : delta South Carolina  1852\n 14 : lambda Kenyon  1852        \n 15 : omega Oakland  1852           \n 16 : eta Virginia  1852           \n 17 : pi Dartmouth  1853           \n 18 : iota Centre  1854         \n 19 : alpha alpha Middlebury  1854\n 20 : omicron Michigan 1855   "
            textBox.text = textToShow
            textBox.textAlignment = .Left
            
        }
        else {
            textToShow = "Something else"
        }
        
      
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
