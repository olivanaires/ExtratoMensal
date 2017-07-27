//
//  ListagemViewController.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 16/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit
import CoreData

class ListagemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var barTitle: UINavigationItem!
    @IBOutlet weak var tabelaValores: UITableView!
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var myDataSource: NSMutableDictionary = NSMutableDictionary()
    var keyDataSource: NSMutableArray = NSMutableArray()
    var keyMesPorAno: NSMutableDictionary = NSMutableDictionary()
    
    var indexMesAnoAtual: NSIndexPath!
    
    let swiftColor: UIColor = UIColor(red: 0.5, green: 0.64, blue: 1, alpha: 0.26)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barTitle.title = NSLocalizedString("extratos", comment: "")
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (indexMesAnoAtual != nil && myDataSource.count > 0) {
            tabelaValores.scrollToRowAtIndexPath(indexMesAnoAtual, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        carregarExtratos()
        tabelaValores.reloadData()
        super.viewWillAppear(animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keyDataSource.count
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let key: String = keyDataSource.objectAtIndex(section) as! String
//        return key
//    }
//    
//    Configura o estilo, cor do footer(parte de baixo da sessão na tabela)
//    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
//        footerView.backgroundColor = UIColor.blackColor()
//        
//        return footerView
//    }
//    
//    Configura o tamanho do footer(parte de baixo da sessão na tabela)
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 40.0
//    }
    
    /*
        Cria célula as sessões informando o ano como titulo
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tabelaValores.dequeueReusableCellWithIdentifier("HeaderCell") as! ListagemHeaderViewCell
        let key: String = keyDataSource.objectAtIndex(section) as! String
        headerCell.labelHeader.text = key
        return headerCell
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let myKey: String = keyDataSource.objectAtIndex(section) as! String
        let sectionList: NSDictionary = myDataSource.objectForKey(myKey) as! NSDictionary
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("extratoDetalhadoSegue", sender: self)
    }
    
    // criado uma segue manual no storeboard que é chamada pelo método tableView(didSelectRowAtIndexPath)
    // esse método prepara o dado a ser enviado para o atributo de ExtratoDetalhadoViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "extratoDetalhadoSegue"{
            let extratoViewController: ExtratoDetalhadoViewController = segue.destinationViewController as! ExtratoDetalhadoViewController
            
            let indexPath = tabelaValores.indexPathForSelectedRow
            
            let key: String = keyDataSource.objectAtIndex(indexPath!.section) as! String
            let grupos: NSDictionary = myDataSource.objectForKey(key) as! NSDictionary
            let mesKeys: NSArray = keyMesPorAno.valueForKey(key) as! NSArray
            let extratoGrupo: NSArray = grupos.valueForKey("\(mesKeys[indexPath!.row])") as! NSArray
            let chave: Int = extratoGrupo.objectAtIndex(1) as! Int
            
            let myFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Extrato")
            let predicate: NSPredicate = NSPredicate(format: "chave == %@", "\(chave)")
            myFetchRequest.predicate = predicate
            
            do {
                let myFetchResult: [NSManagedObject] = try managedContext.executeFetchRequest(myFetchRequest) as! [NSManagedObject]
                
                if ( !myFetchResult.isEmpty ) {
                    let contasSet: NSMutableSet = myFetchResult[0].valueForKey("contas") as! NSMutableSet
                    var contas: [NSManagedObject] = []
                    var contasOrdenadas: [NSManagedObject] = []
                    
                    for conta in contasSet {
                        contas.append(conta as! NSManagedObject)
                    }
                    contasOrdenadas = contas.sort({
                        (s1: NSManagedObject, s2: NSManagedObject) -> Bool in
                        return (s1.valueForKey("data") as! NSDate).compare( (s2.valueForKey("data") as! NSDate) ) == NSComparisonResult.OrderedAscending
                    })
                    extratoViewController.myFetchResultConta = contasOrdenadas
                    extratoViewController.objectId = myFetchResult[0].objectID
                }
            } catch {
                print("erro")
            }
            
            
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = swiftColor
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }

    /*
        Cria célula com mês e valor referente ao mesmo
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myIndex: String = "myIndex"

        let cell = tableView.dequeueReusableCellWithIdentifier(myIndex, forIndexPath: indexPath) as! ListagemTableViewCell
//      Quando não existe um table view cell, essa parte cria a cell
//        if ( cell == nil ) {
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: myIndex)
//        }
        
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        
        let key: String = keyDataSource.objectAtIndex(section) as! String
        let grupos: NSDictionary = myDataSource.objectForKey(key) as! NSDictionary
        let mesKeys: NSArray = keyMesPorAno.valueForKey(key) as! NSArray
        let extratoGrupo: NSArray = grupos.valueForKey("\(mesKeys[row])") as! NSArray
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        let dataAtual: NSDate = NSDate()
        
        dateFormatter.dateFormat = "MMMM"
        let mesAtual: String = dateFormatter.stringFromDate(dataAtual)
        dateFormatter.dateFormat = "yyyy"
        let anoAtual: String = dateFormatter.stringFromDate(dataAtual)
        
        if (mesAtual == "\(mesKeys[row])" && anoAtual == key) {
            indexMesAnoAtual = indexPath
        }
        
        
        let mes: String = "\(mesKeys[row])"
        let valor: Double = extratoGrupo.objectAtIndex(0) as! Double

        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        
        cell.labelMes.text = mes.capitalizedString
        cell.labelValor.text = valorFormatado.stringFromNumber(valor)
//      Adiciona um botão na celula
//        cell.accessoryType = UITableViewCellAccessoryType.DetailButton

        return cell
    }
    
    func carregarExtratos() {
        
        if (myDataSource.count > 0) {
            myDataSource.removeAllObjects()
            keyDataSource.removeAllObjects()
            keyMesPorAno.removeAllObjects()
        }
        
        do {
            let myFetchRequestExtrato: NSFetchRequest = NSFetchRequest(entityName: "Extrato")
            let sortByAnoMes: NSSortDescriptor = NSSortDescriptor(key: "chave", ascending: true)
            myFetchRequestExtrato.sortDescriptors = [sortByAnoMes]
            let myFetchResultExtrato: [NSManagedObject] = try managedContext.executeFetchRequest(myFetchRequestExtrato) as! [NSManagedObject]
            
//            var ultimoAno: String = String()
//            var ultimoMes: String = String()

            if ( !myFetchResultExtrato.isEmpty && myFetchResultExtrato[0].valueForKey("chave") as! Int != 0 ) {
                for extrato in myFetchResultExtrato {
                    let mes: String = extrato.valueForKey("mes") as! String
                    let ano: Int = extrato.valueForKey("ano") as! Int
                    let contas: NSMutableSet = extrato.valueForKey("contas") as! NSMutableSet
                    
                    var valorTotal: Double = 0.0
                    for conta in contas {
                        let valorConta: Double = conta.valueForKey("valor") as! Double
                        valorTotal += valorConta
                    }
                    
                    let chave: Int = extrato.valueForKey("chave") as! Int
                    
                    if (myDataSource["\(ano)"] == nil) {
                        let extrato: NSMutableDictionary = ["\(mes)":[valorTotal,chave]]
                        myDataSource.setValue(extrato, forKey: "\(ano)")
                        keyDataSource.addObject("\(ano)")
                        let mesesKey: NSMutableArray = ["\(mes)"]
                        keyMesPorAno.setValue(mesesKey, forKey: "\(ano)")
                    } else {
                        let extratosAno: NSMutableDictionary = myDataSource.valueForKey("\(ano)") as! NSMutableDictionary
                        extratosAno.setValue([valorTotal,chave], forKey: "\(mes)")
                        let mesesKey: NSMutableArray = keyMesPorAno.valueForKey("\(ano)") as! NSMutableArray
                        mesesKey.addObject(mes)
                    }
                    
//                    ultimoAno = "\(ano)"
//                    ultimoMes = mes
                }
                
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
//                let dataString: String = "01/"+ultimoMes+"/"+ultimoAno
//                let dataInicio:NSDate = dateFormatter.dateFromString(dataString)!
                
                let fetchRequestContaFixa: NSFetchRequest = NSFetchRequest(entityName: "Conta")
                let predicate: NSPredicate = NSPredicate(format: "principal = true AND tipo = 'FIXO'")
                fetchRequestContaFixa.predicate = predicate
                let fetchResultContaFixa: [NSManagedObject] = try managedContext.executeFetchRequest(fetchRequestContaFixa) as! [NSManagedObject]
                
//                let myEntity: NSEntityDescription? = NSEntityDescription.entityForName("Extrato", inManagedObjectContext: managedContext)
//                let extratoMensal: NSManagedObject = NSManagedObject(entity: myEntity!, insertIntoManagedObjectContext: managedContext)
//                let extratoMensalContas: NSMutableSet = extratoMensal.mutableSetValueForKey("contas")
                
                
                var valorTotalFixo: Double = 0
                if(!fetchResultContaFixa.isEmpty) {
                    for contaFixa in fetchResultContaFixa {
                        let valor: Double = contaFixa.valueForKey("valor") as! Double
                        valorTotalFixo += valor
//                        extratoMensalContas.addObject(contaFixa)
                    }
                }
                

                
//                for i in 1...12 {
//                    let mes: String = getValorEmData(dataInicio, formato: "MMMM", nextValue: i)
//                    let ano: String = getValorEmData(dataInicio, formato: "yyyy", nextValue: i)
//                    let chave: Int = Int(getValorEmData(dataInicio, formato: "yyyyMM", nextValue: i))!
//                    
//                    if (myDataSource["\(ano)"] == nil) {
//                        let extrato: NSMutableDictionary = ["\(mes)":[valorTotalFixo,chave]]
//                        myDataSource.setValue(extrato, forKey: "\(ano)")
//                        keyDataSource.addObject("\(ano)")
//                        let mesesKey: NSMutableArray = ["\(mes)"]
//                        keyMesPorAno.setValue(mesesKey, forKey: "\(ano)")
//                    } else {
//                        let extratosAno: NSMutableDictionary = myDataSource.valueForKey("\(ano)") as! NSMutableDictionary
//                        extratosAno.setValue([valorTotalFixo,chave], forKey: "\(mes)")
//                        let mesesKey: NSMutableArray = keyMesPorAno.valueForKey("\(ano)") as! NSMutableArray
//                        mesesKey.addObject(mes)
//                    }
//                }
                
            }
        } catch {
            print("erro")
        }
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
    
    @IBAction func limparBanco(sender: AnyObject) {
        
        let alerta: UIAlertController = UIAlertController(title: "Alerta", message: "Tem certeza que deseja apagar todas as informações cadastradas? Essa ação não pode ser desfeita.", preferredStyle: UIAlertControllerStyle.Alert)
        let acaoSim: UIAlertAction = UIAlertAction(title: "Sim", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            let myFetchRequestConta: NSFetchRequest = NSFetchRequest(entityName: "Conta")
            let myFetchRequestExtrato: NSFetchRequest = NSFetchRequest(entityName: "Extrato")
            let deleteRequestConta: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: myFetchRequestConta)
            let deleteRequestExtrato: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: myFetchRequestExtrato)
            do {
                try self.managedContext.executeRequest(deleteRequestConta)
                try self.managedContext.executeRequest(deleteRequestExtrato)
                try self.managedContext.save()
                self.carregarExtratos()
                self.tabelaValores.reloadData()
            } catch {
                print("erro")
            }
        }
        let acaoCancelar: UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
        alerta.addAction(acaoSim)
        alerta.addAction(acaoCancelar)
        
        self.presentViewController(alerta, animated: true, completion: nil)
        
    }
    
    
}
