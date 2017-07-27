//
//  ViewController.swift
//  ExtratoMensal
//
//  Created by Olivan Aires on 15/11/15.
//  Copyright © 2015 Olivan Aires. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class InserirContaController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var descricaoValue: UITextField!
    @IBOutlet weak var dataValue: UIDatePicker!
    @IBOutlet weak var valorValue: UITextField!
    @IBOutlet weak var parcelaPicker: UIPickerView!

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var parcelaPickerValores: NSMutableArray = NSMutableArray()
    var parcelaPickerSelecionada: String = "1"
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataValue.locale = NSLocale.currentLocale()
        dataValue.setDate(NSDate(), animated:  true )
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        parcelaPickerValores.addObject("Fixo")
        for i in 1...99 {
            parcelaPickerValores.addObject("\(i)")
        }
        parcelaPicker.selectRow(1, inComponent: 0, animated: false)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InserirContaController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InserirContaController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if locationManager.location != nil {
            let latitudeAtual: Double = Double(NSString(format: "%g", locationManager.location!.coordinate.latitude) as String)!
            let longitudeAtual: Double = Double(NSString(format: "%g", locationManager.location!.coordinate.longitude) as String)!
            
            let fetchRequestConta: NSFetchRequest = NSFetchRequest(entityName: "Conta")
            let predicate: NSPredicate = NSPredicate(format: "latitude - (%f) <= 0.0001 AND latitude - (%f) >= -0.0001 AND longitude - (%f) <= 0.001 AND longitude - (%f) >= -0.001", latitudeAtual, latitudeAtual, longitudeAtual, longitudeAtual)
            let sortPorChave: NSSortDescriptor = NSSortDescriptor(key: "data", ascending: false)
            fetchRequestConta.predicate = predicate
            fetchRequestConta.sortDescriptors = [sortPorChave]
            
            let myFetchResultContasPorLocalizacao: [NSManagedObject] = try! managedContext.executeFetchRequest(fetchRequestConta) as! [NSManagedObject]
        
            if !myFetchResultContasPorLocalizacao.isEmpty {
                descricaoValue.text = myFetchResultContasPorLocalizacao[0].valueForKey("descricao") as? String
            } else {
                descricaoValue.text = ""
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y >= 0 {
            self.view.frame.origin.y -= 80
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y <= 0 {
            self.view.frame.origin.y += 80
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        return true
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.startUpdatingLocation()
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parcelaPickerValores.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row: String = parcelaPickerValores.objectAtIndex(row) as! String
        return row
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parcelaPickerSelecionada = parcelaPickerValores[row] as! String
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
    
    func primeiroDiaMes(month:NSInteger, year:NSInteger, day:NSInteger)->NSDate{
        let comp = NSDateComponents()
        comp.month = month
        comp.year = year
        comp.day = day
        let grego = NSCalendar.currentCalendar()
        return grego.dateFromComponents(comp)!
    }
    
    func ultimoDiaMes( date: NSDate ) -> NSDate{
        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = NSDateComponents()
        components.month = 1
        components.setValue(1, forComponent: NSCalendarUnit.Month);
        let nextDate: NSDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))!
        let dateComponents2 = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: nextDate)
        let primeiroDiaMesAtual2: NSDate = primeiroDiaMes(dateComponents2.month, year: dateComponents2.year, day: 1)
        let ultimoDia: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: primeiroDiaMesAtual2, options: NSCalendarOptions (rawValue: 0))!
        return ultimoDia
    }

    
    func getMesAnterior( date: NSDate ) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: date)
        let primeiroDiaMesAtual: NSDate = primeiroDiaMes(dateComponents.month, year: dateComponents.year, day: 1)
        let components: NSDateComponents = NSDateComponents()
        components.setValue(-1, forComponent: NSCalendarUnit.Day);
        let dataAnterior: NSDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: primeiroDiaMesAtual, options: NSCalendarOptions(rawValue: 0))!
        return dataAnterior
    }
    
    func getMes( data: NSDate, nextValue: Int ) -> String {
        let mes: String = getValorEmData(data, formato: "MMMM", nextValue: nextValue)
        return mes
    }
    
    func getNumeroMes( data: NSDate, nextValue: Int ) -> Int {
        let mes: String = getValorEmData(data, formato: "MM", nextValue: nextValue)
        return Int(mes)!
    }
    
    func getAno( data: NSDate, nextValue: Int ) -> Int {
        let ano: String = getValorEmData(data, formato: "yyyy", nextValue: nextValue)
        return Int(ano)!
    }
    
    func getChave(data: NSDate, nextValue: Int) -> Int {
        let chave: String = getValorEmData(data, formato: "yyyyMM", nextValue: nextValue)
        return Int(chave)!
    }
    
    func mostrarAlerta(titulo: String, mensagem: String) {
        let myActionSheet: UIAlertController = UIAlertController(title: titulo, message: mensagem, preferredStyle: UIAlertControllerStyle.Alert)
        let myAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        myActionSheet.addAction(myAction)
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func textFieldReturn(sender: AnyObject) {
        valorValue.becomeFirstResponder()
        sender.resignFirstResponder()
    }
       
    @IBAction func backgroundTouch() {
        descricaoValue.resignFirstResponder()
        valorValue.resignFirstResponder()
    }
    
    func getValorString() -> String {
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        let valorDefaul: String = valorFormatado.stringFromNumber(NSNumber(double: 0.00))!
        let cifrao: String = valorDefaul.substringToIndex(valorDefaul.endIndex.advancedBy(-4))
        
        var valorString: String = valorValue.text!
        valorString = valorString.stringByReplacingOccurrencesOfString(".", withString: "")
        valorString = valorString.stringByReplacingOccurrencesOfString(",", withString: ".")
        valorString = valorString.stringByReplacingOccurrencesOfString(cifrao, withString: "")
        return valorString
    }
    
    func atualizaExtratosPosteriores(chaveConta: String) {
        
        let myEntity: NSEntityDescription? = NSEntityDescription.entityForName("Extrato", inManagedObjectContext: managedContext)
        let myEntityConta: NSEntityDescription? = NSEntityDescription.entityForName("Conta", inManagedObjectContext: managedContext)
        let myFetchRequestExtrato: NSFetchRequest = NSFetchRequest(entityName: "Extrato")
        
        let valor: Double = Double(getValorString())!
        
        var indexProximaChave: Int = 1
        var chave: Int = getChave(dataValue.date, nextValue: indexProximaChave)
        let predicateContasSeguintes: NSPredicate = NSPredicate(format: "chave >= %i", chave)
        let sortPorChave: NSSortDescriptor = NSSortDescriptor(key: "chave", ascending: true)
        myFetchRequestExtrato.predicate = predicateContasSeguintes
        myFetchRequestExtrato.sortDescriptors = [sortPorChave]
        
        do {
        let extratosSeguintes: [NSManagedObject] = try managedContext.executeFetchRequest(myFetchRequestExtrato) as! [NSManagedObject]
        
            if (!extratosSeguintes.isEmpty) {
                
                let chaveUltimoExtrato: Int = extratosSeguintes.last?.valueForKey("chave") as! Int
                
                while(chave <= chaveUltimoExtrato){
                    let conta: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                    conta.setValue(descricaoValue.text, forKey: "descricao")
                    conta.setValue(valor, forKey: "valor")
                    conta.setValue(dataValue.date, forKey: "data")
                    conta.setValue("FIXO", forKey: "tipo")
                    conta.setValue(false, forKey: "principal")
                    conta.setValue(chaveConta, forKey: "chave")
                    
                    var criou: Bool = false
                    for extratoCorrent in extratosSeguintes {
                        let chaveCorrent: Int = extratoCorrent.valueForKey("chave") as! Int
                        if (chave == chaveCorrent) {
                            let contasExtratoCorrent: NSMutableSet = extratoCorrent.valueForKey("contas") as! NSMutableSet
                            conta.setValue(extratoCorrent, forKey: "extrato")
                            contasExtratoCorrent.addObject(conta)
                            try managedContext.save()
                            criou = true
                            break
                        }
                    }
                    
                    if (!criou) {
                        let extratoMensal: NSManagedObject = NSManagedObject(entity: myEntity!, insertIntoManagedObjectContext: managedContext)
                        let extratoMensalContas: NSMutableSet = extratoMensal.mutableSetValueForKey("contas")
                        extratoMensal.setValue(getMes(dataValue.date, nextValue: indexProximaChave), forKey: "mes")
                        extratoMensal.setValue(getAno(dataValue.date, nextValue: indexProximaChave), forKey: "ano")
                        extratoMensal.setValue(chave, forKey: "chave")
                        conta.setValue(extratoMensal, forKey: "extrato")
                        extratoMensalContas.addObjectsFromArray([conta])
                        try managedContext.save()
                    }
                    indexProximaChave += 1
                    chave = getChave(dataValue.date, nextValue: indexProximaChave)
                }
                
            }
        }catch {
            print("erro")
        }
    }
    
    @IBAction func salvar(sender: AnyObject) {
        
        let myEntity: NSEntityDescription? = NSEntityDescription.entityForName("Extrato", inManagedObjectContext: managedContext)
        let myFetchRequestExtrato: NSFetchRequest = NSFetchRequest(entityName: "Extrato")
       
        
        var latitudeAtual: Double = 0.00
        var longitudeAtual: Double = 0.00
        
        if locationManager.location != nil {
            latitudeAtual = Double(NSString(format: "%g", locationManager.location!.coordinate.latitude) as String)!
            longitudeAtual = Double(NSString(format: "%g", locationManager.location!.coordinate.longitude) as String)!
        }
        
        switch (true) {
            
            case self.parcelaPickerSelecionada == "Fixo" && self.valorValue.text != "":
                do {
                    
                    let chave: Int = getChave(dataValue.date, nextValue: 0)
                    let predicate: NSPredicate = NSPredicate(format: "chave = %i", chave)
                    myFetchRequestExtrato.predicate = predicate
                    
                    let extratos: [NSManagedObject] = try managedContext.executeFetchRequest(myFetchRequestExtrato) as! [NSManagedObject]

                    
                    let myEntityConta: NSEntityDescription? = NSEntityDescription.entityForName("Conta", inManagedObjectContext: managedContext)
                    
                    let valor: Double = Double(getValorString())!
                    if ( !extratos.isEmpty ) {
                        
                        let extrato: NSManagedObject = extratos[0]
                        let contasExtrato: NSMutableSet = extrato.valueForKey("contas") as! NSMutableSet
                        let conta: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                        conta.setValue(descricaoValue.text, forKey: "descricao")
                        conta.setValue(valor, forKey: "valor")
                        conta.setValue(dataValue.date, forKey: "data")
                        conta.setValue("FIXO", forKey: "tipo")
                        conta.setValue(true, forKey: "principal")
                        conta.setValue(extrato, forKey: "extrato")
                        conta.setValue(longitudeAtual, forKey: "longitude")
                        conta.setValue(latitudeAtual, forKey: "latitude")
                     
                        let chaveConta: String = NSUUID().UUIDString
                        conta.setValue(chaveConta, forKey:  "chave")
                        contasExtrato.addObject(conta)
                        try managedContext.save()
                    
                        atualizaExtratosPosteriores(chaveConta)
                        
                        
                    } else {
                        let extratoMensal: NSManagedObject = NSManagedObject(entity: myEntity!, insertIntoManagedObjectContext: managedContext)
                        let extratoMensalContas: NSMutableSet = extratoMensal.mutableSetValueForKey("contas")
                        let conta: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                        conta.setValue(descricaoValue.text, forKey: "descricao")
                        conta.setValue(valor, forKey: "valor")
                        conta.setValue(dataValue.date, forKey: "data")
                        conta.setValue("FIXO", forKey: "tipo")
                        conta.setValue(true, forKey: "principal")
                        conta.setValue(extratoMensal, forKey: "extrato")
                        conta.setValue(longitudeAtual, forKey: "longitude")
                        conta.setValue(latitudeAtual, forKey: "latitude")
                        let chaveConta: String = NSUUID().UUIDString
                        conta.setValue(chaveConta, forKey:  "chave")
                        extratoMensalContas.addObjectsFromArray([conta])
                        extratoMensal.setValue(getMes(dataValue.date, nextValue: 0), forKey: "mes")
                        extratoMensal.setValue(getAno(dataValue.date, nextValue: 0), forKey: "ano")
                        extratoMensal.setValue(chave, forKey: "chave")
                        try managedContext.save()
                        
                        atualizaExtratosPosteriores(chaveConta)
                    }
                    
                } catch {
                    mostrarAlerta("Erro", mensagem: "Erro ao consultar informações necessárias!")
                }
                break
            
            case self.parcelaPickerSelecionada != "Fixo" && self.valorValue.text != "":
                do {
                    
                    let numParcela: Int = Int(self.parcelaPickerSelecionada)!
                    let myEntityConta: NSEntityDescription? = NSEntityDescription.entityForName("Conta", inManagedObjectContext: managedContext)
                    let chaveConta: String = NSUUID().UUIDString
                    for parcela in 0 ..< numParcela {
                    
                        let valor: Double = Double(getValorString())!
                        
                        // para cada parcela cria-se uma conta nova que sera adicionada a um extrato
                        let conta: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                        conta.setValue(descricaoValue.text, forKey: "descricao")
                        conta.setValue(valor, forKey: "valor")
                        conta.setValue(parcela+1, forKey: "parcela")
                        conta.setValue(numParcela, forKey: "numParcela")
                        conta.setValue(dataValue.date, forKey: "data")
                        conta.setValue("PARCELADO", forKey: "tipo")
                        conta.setValue(chaveConta, forKey:  "chave")
                        conta.setValue(longitudeAtual, forKey: "longitude")
                        conta.setValue(latitudeAtual, forKey: "latitude")
                        // a primeira parcela(conta) se torna a conta principal
                        if ( parcela == 0 ) {
                            conta.setValue(true, forKey: "principal")
                        } else {
                            conta.setValue(false, forKey: "principal")
                        }
                        
                        // procuro um extrato de acordo com a data da conta criando a chave de busca
                        let chave: Int = getChave(dataValue.date, nextValue: parcela)
                        let predicateExtrato: NSPredicate = NSPredicate(format: "chave = %i", chave)
                        myFetchRequestExtrato.predicate = predicateExtrato
                    
                        /* pego o mes e ano corrente e o primeiro e ultimo dia do mes corrent
                        referente a parcela */
                        let mesCorrent: Int = getNumeroMes(dataValue.date, nextValue: parcela)
                        let anoCorrent: Int = getAno(dataValue.date, nextValue: parcela)
                        let primeiroDiaMesCorrent:NSDate = primeiroDiaMes(mesCorrent, year: anoCorrent, day: 1)
                        let ultimoDiaMesCorrent: NSDate = ultimoDiaMes(primeiroDiaMesCorrent)
                        
                        
                        /* procuro todas as contas do tipo fixa com data menor que o ultimo dia
                         do mes corrente */
                        let fetchRequestContaFixa: NSFetchRequest = NSFetchRequest(entityName: "Conta")
                        let predicateContaFixa: NSPredicate = NSPredicate(format: "principal = true AND data <= %@ AND tipo = 'FIXO'", ultimoDiaMesCorrent)
                        fetchRequestContaFixa.predicate = predicateContaFixa
                        let fetchResultContaFixa: [NSManagedObject] = try managedContext.executeFetchRequest(fetchRequestContaFixa) as! [NSManagedObject]
                        
                        // pego o extrato corrente referente ao mes e ano da parcela
                        let extrato: [NSManagedObject] = try managedContext.executeFetchRequest(myFetchRequestExtrato) as! [NSManagedObject]
                        
                        /* se existir algum, atualizo o mesmo. caso contrario crio um novo para o
                        mes e ano em questão */
                        if ( !extrato.isEmpty ) {
                            
                            /* atualizo as informações do extrato em questão
                            var valorTotal: Double = extrato[0].valueForKey("valorTotal") as! Double
                            valorTotal += valor
                            extrato[0].setValue(valorTotal, forKey: "valorTotal") */
                            conta.setValue(extrato[0], forKey: "extrato")
                            
                            let contasDoExtrato: NSMutableSet = extrato[0].mutableSetValueForKey("contas")
                            
                            var contasParaAdicionar: [NSManagedObject] = []
                            
                            /* percorro todas as contas do extrato em questão
                            ao mesmo tempo que percorro todas as contas do tipo fixo para verificar
                            se as mesmas ja não se encontam no extrato em questão */
                            for conta in contasDoExtrato {

                                let tipoConta: String = conta.valueForKey("tipo") as! String
                                let chaveConta: String = conta.valueForKey("chave") as! String
                                // se o tipo da conta do extrato for fico
                                if ( tipoConta == "FIXO" ) {
                                    // percorro todos as contas fixas encontradas anteriomente
                                    
                                    var descricaoContaFixa: String!
                                    var valorContaFixa: Double!
                                    var dataContaFixa: NSDate!
                                    var chaveContaFixa: String!
                                    var contemContaFixa: Bool = false
                                    for contaFixa in fetchResultContaFixa {
                                        descricaoContaFixa = contaFixa.valueForKey("descricao") as! String
                                        valorContaFixa = contaFixa.valueForKey("valor") as! Double
                                        dataContaFixa = contaFixa.valueForKey("data") as! NSDate
                                        chaveContaFixa = contaFixa.valueForKey("chave") as! String
                                        /** verifico se ela ja se encontra no extrato de acordo com sua
                                        data que possue os minutos e segundos, descrição e valor 
                                        se ela não existir no extrato, adiciono a mesma. **/
                                        if ( chaveConta == chaveContaFixa ) {
                                            contemContaFixa = true
                                            break
                                        }
                                    }
                                    // se a conta não estiver no extrato, a mesma é adicionada
                                    if ( !contemContaFixa && !fetchResultContaFixa.isEmpty ) {
                                        let conta: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                                        conta.setValue(descricaoContaFixa, forKey: "descricao")
                                        conta.setValue(valorContaFixa, forKey: "valor")
                                        conta.setValue(dataContaFixa, forKey: "data")
                                        conta.setValue("FIXO", forKey: "tipo")
                                        conta.setValue(extrato[0], forKey: "extrato")
                                        conta.setValue(chaveContaFixa, forKey:  "chave")
                                        conta.setValue(longitudeAtual, forKey: "longitude")
                                        conta.setValue(latitudeAtual, forKey: "latitude")
                                        contasParaAdicionar.append(conta)
                                    }
                                }
                                
                            }
                            
                            
                            contasDoExtrato.addObject(conta)
                            contasDoExtrato.addObjectsFromArray(contasParaAdicionar)
                            do {
                                try managedContext.save()
                            } catch {
                                mostrarAlerta("Erro", mensagem: "Erro ao salvar as informações!")
                            }
                        } else {
                            /* se não tiver sido encontrado extrato para o filtro informado,
                            crio um novo extrato para o mes/ano em questão */
                            let extratoMensal: NSManagedObject = NSManagedObject(entity: myEntity!, insertIntoManagedObjectContext: managedContext)
                            let extratoMensalContas: NSMutableSet = extratoMensal.mutableSetValueForKey("contas")
                            
                            /* percorro todas as contas fixas encontradas anteriormente
                            adicionando a mesma ao novo extrato */
                            if(!fetchResultContaFixa.isEmpty) {
                                for conta in fetchResultContaFixa {
                                    let valor: Double = conta.valueForKey("valor") as! Double
                                    let contaFixa: NSManagedObject = NSManagedObject(entity: myEntityConta!, insertIntoManagedObjectContext: managedContext)
                                    
                                    var descricao: String = String()
                                    if ( conta.valueForKey("descricao") != nil ) {
                                        descricao = conta.valueForKey("descricao") as! String
                                    }
                                    let dataContaFixa: NSDate = conta.valueForKey("data") as! NSDate
                                    let chaveConta: String = conta.valueForKey("chave") as! String
                                    contaFixa.setValue(descricao, forKey: "descricao")
                                    contaFixa.setValue(valor, forKey: "valor")
                                    contaFixa.setValue(dataContaFixa, forKey: "data")
                                    contaFixa.setValue("FIXO", forKey: "tipo")
                                    contaFixa.setValue(extratoMensal, forKey: "extrato")
                                    contaFixa.setValue(chaveConta, forKey: "chave")
                                    conta.setValue(longitudeAtual, forKey: "longitude")
                                    conta.setValue(latitudeAtual, forKey: "latitude")
                                    extratoMensalContas.addObject(contaFixa)
                                }
                            }
                            
                            // adiciono a conta da parcela ao extrato novo
                            extratoMensalContas.addObject(conta)
                            extratoMensal.setValue(getMes(dataValue.date, nextValue: parcela), forKey: "mes")
                            extratoMensal.setValue(getAno(dataValue.date, nextValue: parcela), forKey: "ano")
                            extratoMensal.setValue(chave, forKey: "chave")
                            do {
                                try managedContext.save()
                            } catch {
                                mostrarAlerta("Erro", mensagem: "Erro ao salvar as informações!")
                            }
                        }
                    
                    }
                    
                } catch {
                    mostrarAlerta("Erro", mensagem: "Erro consultar informações necessárias!")
                }
                
                break
            
            case self.valorValue.text == "":
                mostrarAlerta("Erro", mensagem: "Campo valor deve ser informado!")
                break
            
            default:
                mostrarAlerta("Erro", mensagem: "Verifique se as informações estão corretas!")
                break
            
        }
        limparCampos()
    }
    
    @IBAction func limparCampos() {
        descricaoValue.text = ""
        valorValue.text = ""
        dataValue.setDate(NSDate(), animated: true)
        parcelaPicker.selectRow(1, inComponent: 0, animated: true)
        parcelaPickerSelecionada = "1"
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func mascaraParaValor(sender: AnyObject) {
        
        let valorFormatado: NSNumberFormatter = NSNumberFormatter()
        valorFormatado.numberStyle = .CurrencyStyle
        valorFormatado.locale = NSLocale.currentLocale()
        var valorDefaul: String = valorFormatado.stringFromNumber(NSNumber(double: 0.00))!
        var cifrao: String = valorDefaul.substringToIndex(valorDefaul.endIndex.advancedBy(-4))

        var valorAntigo: String = valorValue.text!
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
        self.valorValue.text = valorDefaul
    }
    
}

