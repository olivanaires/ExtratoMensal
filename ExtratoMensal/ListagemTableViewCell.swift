//
//  ExtratoTableViewCell.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 21/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit

class ListagemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelMes: UILabel!
    @IBOutlet weak var labelValor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
