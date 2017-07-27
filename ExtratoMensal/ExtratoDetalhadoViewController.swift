//
//  ExtratoDetalhadoViewController.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 17/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit
import CoreData

class ExtratoDetalhadoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewExtrato: UITableView!
    
    var myFetchResultConta: [NSManagedObject] = []
    var objectId: NSManagedObjectID!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var indexSelecionado: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        tableViewExtrato.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableViewExtrato.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFetchResultConta.count
    }
    
    func getValorEmData( data: NSDate, formato: String, nextValue: Int ) -> String {
        let components: NSDateComponents = NSDateComponents()
        components.setValue(nextValue, forComponent: NSCalendarUnit.Month);
        let nextDate: NSDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: data, options: NSCalendarOptions(rawValue: 0))!
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formato
        let valor: String = dateFormatter.stringFromDate(nextDate)
        return valor
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // index deve ser setado como identificador da TableViewCell
        let myIndex: String = "myIndex"
        let cell = tableView.dequeueReusableCellWithIdentifier(myIndex, forIndexPath: indexPath) as! ExtratoDetalhadoTableViewCell

        let myObject: NSManagedObject = self.myFetchResultConta[indexPath.row]
        let descricao: String = myObject.valueForKey("descricao") as! String
        let valor: Double = myObject.valueForKey("valor") as! Double
        let numParcela: Int = myObject.valueForKey("parcela") as! Int
        let numTotalParcela: Int = myObject.valueForKey("numParcela") as! Int
        let data: NSDate = myObject.valueForKey("data") as! NSDate
        let dataString: String = getValorEmData(data, formato: "dd/MM/yyyy", nextValue: 0)
    
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        
        cell.fieldDescricao.text = "\(descricao)"
        cell.fieldParcela.text = "\(numParcela)/\(numTotalParcela)"
        cell.fieldValor.text = valorFormatado.stringFromNumber(valor)
        cell.fieldData.text = "\(dataString)"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            mostrarAlertaExcluirContasRelacionadas(indexPath)
        }
    }
    
    func mostrarAlertaExcluirContasRelacionadas(indexPath: NSIndexPath){
        let alerta: UIAlertController = UIAlertController(title: "Alerta", message: "Você deseja excluir as contas relacionadas?", preferredStyle: UIAlertControllerStyle.Alert)
        let myObject: NSManagedObject = self.myFetchResultConta[indexPath.row]
        let acaoSim: UIAlertAction = UIAlertAction(title: "Sim", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            do {
                self.myFetchResultConta.removeAtIndex(indexPath.row)
                self.tableViewExtrato.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                let conta: NSManagedObject = try self.managedContext.existingObjectWithID(myObject.objectID)
                let chave: String = conta.valueForKey("chave") as! String
                let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Conta")
                let predicate: NSPredicate = NSPredicate(format: "chave = %@", chave)
                fetchRequest.predicate = predicate
                let fetchResult: [NSManagedObject] = try self.managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                
                if (!fetchResult.isEmpty) {
                    for conta in fetchResult {
                        self.managedContext.deleteObject(conta)
                    }
                }
                try self.managedContext.save()
            } catch {
                print("erro")
            }
        }
        let acaoNao: UIAlertAction = UIAlertAction(title: "Não", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            do {
                self.myFetchResultConta.removeAtIndex(indexPath.row)
                self.tableViewExtrato.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                let conta: NSManagedObject = try self.managedContext.existingObjectWithID(myObject.objectID)
                self.managedContext.deleteObject(conta)
                try self.managedContext.save()
            } catch {
                print("erro")
            }
        }
        
        alerta.addAction(acaoSim)
        alerta.addAction(acaoNao)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    //    Adiciona um evento para o botão na celula
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.indexSelecionado = indexPath.row
        self.performSegueWithIdentifier("contaDetalhadaSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "contaDetalhadaSegue" {
            let contaSelecionada: NSManagedObject = myFetchResultConta[indexSelecionado]
            
            let contaDetalhadaViewController: ContaDetalhadaViewController = segue.destinationViewController as! ContaDetalhadaViewController
            contaDetalhadaViewController.conta = contaSelecionada
        }
    }
    
}
