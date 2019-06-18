# ImageStore

ImageStore is a light weight library that allows to fetch images from an URL and cache them for continuous use.
It is designed to use with SwiftUI and Swift 5.1 and up.

## Instalation
### Swift Package Manager
1. Copy the git URL 
2. On Xcode, go to File -> Swift Packages -> Add Package Dependency
3. Paste the URL
4. Configure the desired versions

## Usage
On the view you wish to load the image, add a `@ObjectBinding` to ImageStore.
On that same view, add a method that will load the image, eg fetch()
Load an `Image` object with the resulting `ImageStore.image`
When the view is loaded, call the `fetch()` method and send the url you wish to load.

```swift
struct ViewThumbnail : View {
    var thumbnailUrl: String
    @ObjectBinding var imageStore: ImageStore
    
    init(url: String) {
        thumbnailUrl = url
        imageStore = ImageStore()
    }

    var body: some View {        
        Image(uiImage: imageStore.image)
            .resizable()
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            .frame(width: 100, height: 200)
            .clipped(antialiased: true)
            .onAppear(perform: fetch)
    }
    
    private func fetch() {
        imageStore.getImage(from: thumbnailUrl)
    }
}
```


### Note
The package creates a folder where it store the images. After the initial load, the images are stored in cache.
Persistence is maintained for 30 days before a new request is needed.
Requests to revalidate the cache are made automaticly.
