//
//  Sound.swift
//  iOSSystemSounds
//
//  Created by Wayne Yeh on 2017/9/21.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import AVFoundation

struct Sound {
    let fileName: String
    let path: URL
    let duration: Double
    
    static let systemSounds: [Sound] = {
        filesOnFolder(path: "/System/Library/Audio/UISounds").map{
            Sound(fileName: $0.deletingPathExtension().lastPathComponent,
                  path: $0,
                  duration:CMTimeGetSeconds(AVURLAsset(url: $0).duration))
        }
    }()
    
    static func filesOnFolder(path: String) -> [URL] {
        var urls = [URL]()
        
        if let subfiles = try? FileManager.default.contentsOfDirectory(atPath: path) {
            urls.append(contentsOf:
                subfiles.filter{
                    $0.hasSuffix(".caf")
                }.map{
                    URL(fileURLWithPath: "\(path)/\($0)")
                }
            )
        }
        
        if let subpaths = FileManager.default.subpaths(atPath: path) {
            for subpath in subpaths {
                let subfolder = "\(path)/\(subpath)"
                let subfiles = filesOnFolder(path: subfolder)
                urls.append(contentsOf: subfiles)
            }
        }
        
        return urls
    }
}
