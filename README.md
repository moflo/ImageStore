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
On the view you wish to load the image, add a @EnvironmentObject of type ImageStore
On that same view add a method that will load the image, eg fetch()
Have an Image object, referencing the ImageStore.image
When the view is loaded, call the fetch() method and send the url you wish to load.

    struct ViewThumbnail : View {
        var thumbnailUrl: String
        @EnvironmentObject var imageStore: ImageStore

        var body: some View {
            let screenSize = UIScreen.main.bounds
            return Image(uiImage: imageStore.image)
                .resizable()
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipped(antialiased: true)
                .onAppear(perform: fetch)
        }
    
        private func fetch() {
            imageStore.getImage(from: thumbnailUrl)
        }
    
    }


### Note
The package creates a folder where it store the images. after the initial load the images are stored in cache.
Persistence is maintained for 30 days before a new request is needed.
Requests are made automaticly.
