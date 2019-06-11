//
//  ImageStore.swift
//  aCultural
//
//  Created by Joao Pires on 09/06/2019.
//  Copyright © 2019 Joao Pires. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
import SwiftUI
import Combine

@available(iOS 13, macOS 10.15, tvOS 13, *)
public class ImageStore: BindableObject {
    // MARK: - Properties
    #if os(iOS) || os(tvOS)
    static var images: [URL: UIImage] = [:]
    public var image: UIImage = UIImage() {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(self)
            }
        }
    }
    #elseif os(OSX)
    static var images: [URL: NSImage] = [:]
    public var image: NSImage = NSImage() {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(self)
            }
        }
    }
    #endif
    public var didChange = PassthroughSubject<ImageStore, Never>()
    public var documentsDirectory: URL

    // MARK: - Initializer
    public init() {
        let manager = FileManager.default
        let paths = manager.urls(for: .documentDirectory, in: .userDomainMask)
        documentsDirectory = paths[0].appendingPathComponent("Images", isDirectory: true)
        do {
            try manager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("Debug Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Method
    /// Requests an image from the given link. Subsequent requests will load the cached image for a maximum of 30 days.
    /// The return value will be as a bindable ImageStore object, with an image property.
    /// - Parameter urlString: a url that directs to an image.
    public func getImage(from urlString: String) {

        DispatchQueue.global().async {

            guard let url = URL(string: urlString) else { return }
            if !self.loadFromCache(url) {

                self.loadImage(fromUrl: url)
                if let data = try? Data(contentsOf: url) {

                    self.save(data, forUrl: url)
                    #if os(iOS) || os(tvOS)
                    guard let loadedImage = UIImage(data: data) else { return }
                    #elseif os(OSX)
                    guard let loadedImage = NSImage(data: data) else { return }
                    #endif
                    self.image = loadedImage
                }
            }
        }
    }

    // MARK: - Private Methods
    private func save(_ data: Data, forUrl url: URL) {

        let imageName = url.lastPathComponent
        let imageDestinationUrl = documentsDirectory.appendingPathComponent(imageName, isDirectory: false)
        if saveToDisk(url) {
            do {
                try data.write(to: imageDestinationUrl, options: [])
            }
            catch {
                print("Debug Error: \(error.localizedDescription)")
            }
        }
    }

    private func loadImage(fromUrl url: URL) {

        let imageName = url.lastPathComponent
        let imageDestinationUrl = documentsDirectory.appendingPathComponent(imageName, isDirectory: false)
        if let data = try? Data.init(contentsOf: imageDestinationUrl) {

            #if os(iOS) || os(tvOS)
            guard let loadedImage = UIImage(data: data) else { return }
            #elseif os(OSX)
            guard let loadedImage = NSImage(data: data) else { return }
            #endif
            self.image = loadedImage
            DispatchQueue.main.async {

                ImageStore.images.updateValue(loadedImage, forKey: url)
            }
        }
    }

    private func loadFromCache(_ url: URL) -> Bool {

        if let image = ImageStore.images[url] {
            self.image = image
            return true
        }
        return false
    }

    private func saveToDisk(_ url: URL) -> Bool {

        let userDefaults = UserDefaults.standard
        let imageName = url.lastPathComponent
        if let savedDate = userDefaults.value(forKey: imageName) as? Date {

            let currentDate = Date()
            let currentTime = currentDate.timeIntervalSince1970
            let savedTime = savedDate.timeIntervalSince1970
            let difference = currentTime - savedTime
            // Reference: 30 days
            let reference = 60 * 60 * 24 * 30
            if Int(difference) > reference {

                userDefaults.set(Date(), forKey: imageName)
                return true
            }
            else {

                return false
            }
        }
        else {

            userDefaults.set(Date(), forKey: imageName)
            return true
        }
    }
}
