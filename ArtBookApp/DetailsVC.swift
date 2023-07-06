//
//  DetailsVC.swift
//  ArtBookApp
//
//  Created by Efekan Güvendik on 31.05.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageVieaw: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    
    //aşşağıda tekrar tıklamada resim infosunu geri açmayı göstericez.
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "sec")!)
        
        //tekrar tıklamada if else ile bu işlemin kararlığını yapıyoruz.
        if choosenPainting != ""{
            
            ///Şimdi burada detay giriyoruz yani eğer image yok ise veya zaten save alınmış bir işlem var ise
            ///Save button ya olmıyacak yada gözükmeyecek
            saveButton.isEnabled = false
            
            
            ///core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            ///burada aşşağıdaki işlem satırı bize daha doğrusu predicate olan kısım şu demek oluyor
            ///bir işlem bloğu yazıcaz ve bize sadece o işlme bloğu içindeki öğeleri döndürecek
            ///yani tanımlanana sınırlar içinde mantıksal tanımlar demek yani
            ///seçilen öğeler arasında bir artis bir yıl ve bir isi gibi
            let idString = choosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)// bu id si şurdaki yazan argumana eşit olanı  bul demek
            //ve bunu name den de yaparız ancak ya aynı ismli 2 veya fazla şey olursa ondan id den yaparz hepsi farklı olsun.
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    ///bu işlemden sora mecburan for loop a sokucaz çünki NSMonject dizisi içinde verilecek
                    ///yani her türlü bize bir dizi vericek.
                    for restult in results as! [NSManagedObject]{
                        if let name = restult.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = restult.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = restult.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = restult.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData )
                            imageVieaw.image = image
                        }
                    }
                    
                    
                }
                
            }catch{
                print("Error")
                
            }
            
            
            
        }else{
            
             saveButton.isEnabled = false
            
            nameText.text = ""
            yearText.text = ""
            artistText.text = ""
        }
        
        
        
        
        ///-----Recognizer-----///
        //keyboardı gizlemek lazım bunun için recognizer yapıcaz
        let gesRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        view.addGestureRecognizer(gesRecognizer)
        
        //kullanıcı görsele tıklayabiliyormu diye bir tane daha gesRecognizer ekliycez.
        imageVieaw.isUserInteractionEnabled = true // bu şekilde tıklana bilir yapdık
        let imageTabRecognizer  = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        //son olarak buna bu özelliği entegre edelim.
        imageVieaw.addGestureRecognizer(imageTabRecognizer)
    }
    
    //kullanıcı image e tıklaması için buraya bir select func giricez
    @objc func selectImage(){
        //peki burda kullanıcıyı galeriye nasıl götürcez onu da şu şekilde picker diye bir etken ile.
        let picker = UIImagePickerController()
        //ancak bunu kullanmak için pickerin kendi kütüphanesini kullanmak lazım.
        picker.delegate = self/// kısaca galeri için picker adlı fonksiyonu kullanıyoruz
        ///onunda işe yaraması için delege olarak ayarladık.
        ///şimdi bu picker ın nereden almasını istiyorsak orayı ayarlıycaz oda alta
        picker.sourceType = .photoLibrary
        //birde buna editing istiyorsak onu da altdaki gibi yaparız
        picker.allowsEditing = true
        present(picker , animated: true)//buraya kadar tamam ama bundan sora kullanıcı ne yapacak onu söylemek lazım.
    }
    
      //işde yukarıda bahsi geçen image açıldık dan sora ne olcuak olayına burada
      //yazmış olduğumuz delegate ler işe yarıcak
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageVieaw.image = info[.originalImage] as? UIImage //burda as? koymassak opsiyonel olarak algılamaz ve any vermeye kalkar .
        
        //---SAVE BUTTON TIKLANABİLİRİ OLMASINI BURDA YAPIYORUZ---
        saveButton.isEnabled = true
        // son olarak kapatmak için
        self.dismiss(animated: true)
    }
    
    @objc func hidekeyboard(){
        view.endEditing(true)//bu işlemi bitir demek ve otomatik olarak klavye gizler.
    }
    
    @IBAction func saveButton(_ sender: Any) {

     
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
     
        //contextin içine ne koyacağız
        //burada bir newpainting kayıt edicez ama bunun için yukarı bir core data class açmamız lazım
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        //yukarıda hedef verdik.
        // yukarıda şunu yaptık paintings içine kayıt etmeyi aşşağıda göstericez.
        
        ///---Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")

        }
        
        newPainting.setValue(UUID(), forKey: "id")
        //image data ya çevirme.
        let data = imageVieaw.image?.jpegData(compressionQuality: 0.5)
        //bu image yi data ya çevireyim ve bize yüzde kaçını alayım diyor.
        newPainting.setValue(data , forKey: "image")
        
        do {
            try context.save()
            print("Success")
        }catch{
            print("Error!")
        }
        ///peki yeni bir foto kayıt ettik ama ekranda çıkmıyor çümki sayfa kendini yenilemiyor.
        ///bunun için aşşağıdaki kod satırından işlemi tekrar etmesini isteğieceğiz.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true) ///bir önceki viewControlölre geri dönüş.
        

        
    }
    
    
    
    
}
