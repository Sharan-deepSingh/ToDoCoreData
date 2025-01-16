//
//  ToDoCell.swift
//  ToDoCoreData
//
//  Created by Sharandeep Singh on 22/12/24.
//

import UIKit

class ToDoCell: UITableViewCell {
    
    var deleteToDo: ((Int) -> Void)?
    var index: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - IBOutlets
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deleteToDo?(index ?? 0)
    }
}
