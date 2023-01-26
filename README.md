# Todoey ✓

Todoey is a simple to-do list app. 

## How does it work?

The application is made up of two screens: category list view and item list view. First, once the appliction is opened, you can click the add button and make a new category. Then, inside the category, you can create to-do items and check each item to mark them as done or simply swipe them left to delete. 
The application uses MVC design pattern and Realm as the database. In order to make UITableView cells swipeable, SwipeCellKit framework was installed. Also, to assign a random color to a newly created category cell, Chameleon color framework was installed. This framework is also used to create gradient colors for items in a category and a contrasting color for navigation bar title and bar button.




https://user-images.githubusercontent.com/88018675/214747245-d121c780-a476-4161-aed4-d69d83f5b585.MP4


### AppDelegate
First, Realm is initialized here and errors are handled. Also, RealmSwift framework is imported.

### DataModel
Let me explain how the data models were declared. First, two model classes were created, both subclassing Realm Object class. Then, the properties of each class were declared. Inside Category class, one-to-many relationship was created by declaring List of Item objects: 

        let items = List<Item>() 
        
After that, an inverse relationship was created inside the Item class:

        var parentCategory = LinkingObjects(fromType: Category.self, property: “items”) 
        
LinkingObjects creates the object (Item class) that is linked to its owning model object (Category parent class) through a property “items”. These relationships help us to navigate from a category to its items and from items back to their parent category. 


### CRUD methods

Realm CRUD methods, except for querying, all have to be used in realm.write {  } transaction. 
Creating instances in this project are: 

        realm.add(category) 

and 

        currentCategory.items.append(newItem)

in CategoryViewController and TodoListViewController respectively. 
To read or query for the Category objects, we used: 

        categoryArray = realm.objects(Category.self) 
        
This block of code returns a Results object that includes all Category type objects from realm. 
Updating also happens in write {} transaction. For example, in didSelectRowAt() method in TodoListViewController: 

        try realm.write { 
          item.done = !item.done 
        }
        
Deletion is similar too: 

        try realm.write { 
          realm.delete(selectedItem) 
        }
        
In conclusion, I learned about Realm database, SwipeCellKit and ChameleonFramework while making this application. 










>This is a companion project to The App Brewery's Complete iOS Development Bootcamp, check out the full course at [www.appbrewery.co](https://www.appbrewery.co/)


