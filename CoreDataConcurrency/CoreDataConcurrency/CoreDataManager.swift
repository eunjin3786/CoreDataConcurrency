import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataConcurrency")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: CRUD - Create
    func createStudent(name: String, age: Int) {
        let context = backgroundContext
        
        DispatchQueue.global().async {
            context.performAndWait {
                let studentEntity = NSEntityDescription.entity(forEntityName: "Student", in: context)!
                let student = NSManagedObject(entity: studentEntity, insertInto: context)
                student.setValue(name, forKey: "name")
                student.setValue(age, forKey: "age")
                
                do {
                    print("isMainTread \(Thread.current.isMainThread)")
                    try context.save()
                } catch let error as NSError {
                    print(("\(error) \(error.userInfo)"))
                }
            }
        }
    }
    
    // MARK: CRUD - Retreive
    func retrieveAll() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        do {
            let result = try context.fetch(fetchRequest)
            let students = (result as? [Student])?.map { $0.name }
            print(students)
        } catch let error as NSError {
            print(("\(error) \(error.userInfo)"))
        }
    }
    
    // MARK: CRUD - Delete
    func deleteAll() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        do {
            let result = try context.fetch(fetchRequest)
            result.compactMap { $0 as? NSManagedObject }.forEach {
                context.delete($0)
            }
            try context.save()
        } catch let error as NSError {
            print(("\(error) \(error.userInfo)"))
        }
    }
}
