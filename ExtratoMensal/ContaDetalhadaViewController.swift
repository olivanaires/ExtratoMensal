//
//  ContaDetalhadaViewController.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 23/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit
import CoreData

class ContaDetalhadaViewController: UIViewController {
    
    @IBOutlet weak var descricaoField: UILabel!
    @IBOutlet weak var dataField: UILabel!
    @IBOutlet weak var parcelasField: UILabel!
    @IBOutlet weak var valorField: UILabel!
    
    @IBOutlet weak var valorText: UITextField!
    @IBOutlet weak var descricaoText: UITextField!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var conta: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let descricao: String = conta.valueForKey("descricao") as! String
        let data: NSDate = conta.valueForKey("data") as! NSDate
        let parcela: Int = conta.valueForKey("parcela") as! Int
        let numParcela: Int = conta.valueForKey("numParcela") as! Int
        let valor: Double = conta.valueForKey("valor") as! Double
        var textoParcela: String = String()
        
        if (parcela != 0 && numParcela != 0) {
           textoParcela = "\(parcela)/\(numParcela)"
        } else {
            textoParcela = "Fixa"
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        
        descricaoField.text = descricao
        dataField.text = formatter.stringFromDate(data)
        parcelasField.text = textoParcela
        valorField.text = valorFormatado.stringFromNumber(valor)
        
        valorText.text = valorFormatado.stringFromNumber(valor)
        descricaoText.text = descricao
        
    }
    
    @IBAction func textfieldReturn(sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTouch() {
        valorText.resignFirstResponder()
    }

    @IBAction func voltarExtratoDetalhado(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editarConta(sender: AnyObject) {
        descricaoField.hidden = true
        dataField.hidden = false
        parcelasField.hidden = false
        valorField.hidden = true
        
        valorText.hidden = false
        descricaoText.hidden = false
    }
    
    @IBAction func mascaraDoValor(sender: AnyObject) {
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        var valorDefaul: String = valorFormatado.stringFromNumber(NSNumber(double: 0.00))!
        var cifrao: String = valorDefaul.substringToIndex(valorDefaul.endIndex.advancedBy(-4))
        
        var valorAntigo: String = valorText.text!
        valorAntigo = valorAntigo.stringByReplacingOccurrencesOfString(".", withString: "")
        valorAntigo = valorAntigo.stringByReplacingOccurrencesOfString(",", withString: "")
        valorAntigo = valorAntigo.stringByReplacingOccurrencesOfString(cifrao, withString: "")
        valorAntigo = "\(Int(valorAntigo)!)"
        
        switch (true) {
        case valorAntigo.characters.count < 3:
            valorDefaul.replaceRange(valorDefaul.endIndex.advancedBy(-valorAntigo.characters.count) ..< valorDefaul.endIndex, with: valorAntigo)
            break
            
        case valorAntigo.characters.count == 3:
            valorDefaul = valorDefaul.stringByReplacingOccurrencesOfString(".", withString: "")
            valorDefaul = valorDefaul.stringByReplacingOccurrencesOfString(",", withString: "")
            valorDefaul.replaceRange(valorDefaul.endIndex.advancedBy(-valorAntigo.characters.count) ..< valorDefaul.endIndex, with: valorAntigo)
            let index = valorDefaul.endIndex.advancedBy(-2)
            valorDefaul.insert(",", atIndex: index)
            break
            
        case valorAntigo.characters.count < 6:
            cifrao.appendContentsOf(valorAntigo)
            valorDefaul = cifrao
            let indexVirgula = valorDefaul.endIndex.advancedBy(-2)
            valorDefaul.insert(",", atIndex: indexVirgula)
            break
            
        case valorAntigo.characters.count < 9:
            cifrao.appendContentsOf(valorAntigo)
            valorDefaul = cifrao
            let indexVirgula = valorDefaul.endIndex.advancedBy(-2)
            let indexPrimeiroPonto = valorDefaul.endIndex.advancedBy(-5)
            valorDefaul.insert(",", atIndex: indexVirgula)
            valorDefaul.insert(".", atIndex: indexPrimeiroPonto)
            break
            
        default:
            cifrao.appendContentsOf(valorAntigo)
            valorDefaul = cifrao
            let indexVirgula = valorDefaul.endIndex.advancedBy(-2)
            let indexPrimeiroPonto = valorDefaul.endIndex.advancedBy(-5)
            let indexSegundoPonto = valorDefaul.endIndex.advancedBy(-8)
            valorDefaul.insert(",", atIndex: indexVirgula)
            valorDefaul.insert(".", atIndex: indexPrimeiroPonto)
            valorDefaul.insert(".", atIndex: indexSegundoPonto)
            break
        }
        self.valorText.text = valorDefaul
    }
   
    func getValorString() -> String {
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        let valorDefaul: String = valorFormatado.stringFromNumber(NSNumber(double: 0.00))!
        let cifrao: String = valorDefaul.substringToIndex(valorDefaul.endIndex.advancedBy(-4))
        
        var valorString: String = valorText.text!
        valorString = valorString.stringByReplacingOccurrencesOfString(".", withString: "")
        valorString = valorString.stringByReplacingOccurrencesOfString(",", withString: ".")
        valorString = valorString.stringByReplacingOccurrencesOfString(cifrao, withString: "")
        return valorString
    }
    
    @IBAction func salvarAlteracao(sender: AnyObject) {
        
        do {
            let conta: NSManagedObject = try self.managedContext.existingObjectWithID(self.conta.objectID)
            let chave: String = conta.valueForKey("chave") as! String
            let novoValor: Double = Double(getValorString())!
            let novaDescricao: String = descricaoText.text!
            
            let alerta: UIAlertController = UIAlertController(title: "Alerta", message: "Deseja replicar essa alteração para todas as contas relacionadas?", preferredStyle: UIAlertControllerStyle.Alert)
            
            let acaoSim: UIAlertAction = UIAlertAction(title: "Sim", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Conta")
                let predicate: NSPredicate = NSPredicate(format: "chave = %@", chave)
                fetchRequest.predicate = predicate
                do {
                    let fetchResult: [NSManagedObject] = try self.managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                    
                    if !fetchResult.isEmpty {
                        for conta in fetchResult {
                            conta.setValue(novoValor, forKey: "valor")
                            conta.setValue(novaDescricao, forKey: "descricao")
                            try self.managedContext.save()
                        }
                    }
                } catch {
                    print("")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            let acaoNao: UIAlertAction = UIAlertAction(title: "Não", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                do {
                    conta.setValue(novoValor, forKey: "valor")
                    conta.setValue(novaDescricao, forKey: "descricao")
                    try self.managedContext.save()
                } catch {
                    print("")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            let acaoCancelar: UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alerta.addAction(acaoSim)
            alerta.addAction(acaoNao)
            alerta.addAction(acaoCancelar)
            
            self.presentViewController(alerta, animated: true, completion: nil)
        } catch {
            print("")
        }

    }
    
    @IBAction func cancelarAcao(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
