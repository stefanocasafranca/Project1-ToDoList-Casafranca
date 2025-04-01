//
//  ToDoCell.swift
//  Project1-ToDoList-Casafranca
//
//  Created by Stefano Casafranca on 3/30/25.
//

import UIKit


protocol ToDoCellDelegate: AnyObject {
    func checkmarkTapped(sender: ToDoCell)
}

//This class defines two outlets: a checkmark button (isCompleteButton) and a label for the to-do title (titleLabel). It also declares a protocol ToDoCellDelegate to notify when the checkmark button is tapped. The cell’s completeButtonTapped IBAction calls the delegate method, which will allow the view controller to update the model when the user taps the checkmark.

class ToDoCell: UITableViewCell {

        @IBOutlet var isCompleteButton: UIButton!
        @IBOutlet var titleLabel: UILabel!
        
        weak var delegate: ToDoCellDelegate?
        
        @IBAction func completeButtonTapped(_ sender: UIButton) {
            delegate?.checkmarkTapped(sender: self)
        }
    
    
    /*Errase this default code
     override func awakeFromNib() {
         super.awakeFromNib()
         // Initialization code
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }*/
    
    
    }

    
