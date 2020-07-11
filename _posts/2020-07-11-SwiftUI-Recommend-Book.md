---
layout: post
title: SwiftUI Recommend Book 
date: 2020-07-11 21:50:00
comments: true
disqus_category_id: SwiftUIRecommendBook 
categories: [Swift]
tags: [SwiftUI]
---

In previous article we know how to parse website books information data, and save & process them in MongoDB database. In this one, we will mainly forcus on how to use SwiftUI to create an iOS app to call related API and get the recommended book list.

## APIClient & Request

Most of iOS engineer should be familiar with this part, so I will jump this description. If someone is interested in this part, you could directly check: <https://github.com/HevaWu/RecommendBook/tree/master/RecommendBook/API>

## SwiftUI Dynamic Fetching API List

Actually, one of the reason to create this app is because I would like to try SwiftUI 🤪.

I just generate the search view very simple: top part is search area, later os the Search Result list which will put the api results.

If you tried SwiftUI before, you might know we could use `List` to generate a view like `tableView`. So, actually, the hard thing for me at here is how to update the list automatically after calling API.

After doing some research, I found we could use `ObservableObject` & `Published`. By setting an object as `ObservableObject`, it kind of telling this object's value might be changed later. And by setting one variable of this object as `Published`, means we could monitoring this variable's value changing in SwiftUI later.

So, the code part is like:

```swift
/// --- ObservableObject
final class BookRelationFinder: ObservableObject {
    
    @Published var booksData: [Book] = []
    
    func findRelatedBooks(title: String, completion: ((Result<[Book], APIError>) -> Void)? = nil) {
        APIClient.shared.send(request: GetRelationBookListRequest(title: title)) { [unowned self] res in
            switch res {
            case let .success(data):
                let books = data.map { Book(rel: $0) }
                completion?(.success(books))
                print(books.count)
                DispatchQueue.main.async {
                    self.booksData = books
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}

/// --- SwiftUI ContentView
@ObservedObject var bookFinder = BookRelationFinder()
// tricky things at here is we could directly use `bookFinder.booksData` at here and value will be changed automatically after calling API
List(bookFinder.booksData) { book in
	HStack {
		Image("default-cover")
			.resizable()
			.cornerRadius(4)
			.frame(width: 50, height: 70, alignment: .leading)
		VStack(alignment: .leading, spacing: 5) {
			Text(book.title)
				.bold()
			Text(book.relation)
		}
	}
}
```

## Running

![amazonJPparser](/images/2020-07-11-SwiftUI-Recommend-Book/amazonJPparser.gif#simulator)

## Project Link

You could check the whole code at: <https://github.com/HevaWu/RecommendBook>

But you might not be able to run it after click `Search`, it is because I'm using a private server to save data. So if you are interested in the data, you might want to check previous ariticle to see how to parse data 😆
