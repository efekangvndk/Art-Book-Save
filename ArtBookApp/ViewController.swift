//
//  ViewController.swift
//  ArtBookApp
//
//  Created by Efekan Güvendik on 28.05.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    //select işlemi ekran açma.
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "first")!)
        
        //çağırdığımız delegate ve datasource'u çağıralım.
        tableView.delegate = self
        tableView.dataSource = self //ama bunlar yetmez birde bunlar için sıra ve kaç kez func yazmamız lazım.
        
        
        
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonCliked))
        ///yukarıda yazmış olduğumuz kod ile table viewun üstüne ulaşdık.
        ///ve bir button ekledik.
        
        getData()
    }
    
    ///iyi güzel bunca şey yapıldı ancak bunları nasıl data ya kayıt edicez bunun içinse aşşağıdaki fonksiyonları
    ///yazıp bu işmeleri appimize tanıtmamız lazım.
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    //bu işlemeri çekmemiz lazım yani çağırmamaız ondan ötürü bir getdata değişkeni ile appdelegateden çağırıyoruz.
    @objc func getData (){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //bundan sora bizim fetch denen yani tut getir çeviris olan bir kod ile hafızadan itemları almamız lazım
        //bunu da try cath ile ve fetch ile yaparız hem hata vermez hem işlem tamamlanır.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false //bunun amacı tutlan öğenin tekrara düşmemesi.
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for restult in results as! [NSManagedObject]{
                    if let  name = restult.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let  id  = restult.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    
                    self.tableView.reloadData()

                }
                
            }
            
            }catch{
                print("Error")
            }
        }
        
    
    
    
    @objc func addButtonCliked(){
        
        selectedPainting = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //kaç kez
       return nameArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//hangi sıraylar.
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    
    //tekrar info olayında diğer viewControlöre aktarma işemi segue...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationsVC = segue.destination as! DetailsVC
            destinationsVC.choosenPainting = selectedPainting
            destinationsVC.choosenPaintingId = selectedPaintingId
        }
    }
    
    
    ///tıklandığında nereye gitmesi isteniyorsa. bu işlem ile + ya tıklanınca boş resme tıklandıysa bir isme tıklandı deniyor.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
    //delete action
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let idString = idArray[indexPath.row].uuidString
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            //yanlızca bir veri bulup silmek istiyoruz onun için predicate den o veriyi istyicez
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)

                if results.count > 0 {
                    for result in results as![NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("Error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("Error")
            }
             
        }
    }
    
}
  
