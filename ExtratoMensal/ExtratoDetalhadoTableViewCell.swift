//
//  ExtratoDetalhadoTableViewCell.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 18/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit

class ExtratoDetalhadoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldDescricao: UILabel!
    @IBOutlet weak var fieldParcela: UILabel!
    @IBOutlet weak var fieldValor: UILabel!
    @IBOutlet weak var fieldData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
