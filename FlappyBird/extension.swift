//
//  extension.swift
//  FlappyBird
//
//  Created by Fernando García Hernández on 27/2/18.
//  Copyright © 2018 Fernando García Hernández. All rights reserved.



/*  Este archivo extiende la clase CGFloat añadiendo el metodo "random" que toma dos valores y devuelve un numero aleatorio entre ellos  */

import Foundation
import CoreGraphics

public extension CGFloat{
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max-min) + min
    }
    
}
