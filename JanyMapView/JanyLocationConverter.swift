//
//  JanyLocationConverter.swift
//  Example
//
//  Created by Jany on 2017/11/10.
//  Copyright © 2017年 MillionConcept. All rights reserved.
//

import UIKit
import CoreLocation

class JanyLocationConverter: NSObject {
    
    let RANGE_LON_MAX:Double = 137.8347
    let RANGE_LON_MIN:Double = 72.004
    let RANGE_LAT_MAX:Double = 55.8271
    let RANGE_LAT_MIN:Double = 0.8293
    
    let jzA:Double = 6378245.0
    let jzEE:Double = 0.00669342162296594323
    
    //MARK: Class function

	func wgs84ToGcj02(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return gcj02Encrypt(ggLat: location.latitude, ggLon: location.longitude)
    }
    
    func gcj02ToWgs84(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return gcj02Decrypt(gjLat: location.latitude, gjLon: location.longitude)
    }
    
    func wgs84ToBd09(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let gcj02Pt:CLLocationCoordinate2D = gcj02Encrypt(ggLat: location.latitude, ggLon: location.longitude)
        return bd09Encrypt(ggLat: gcj02Pt.latitude, ggLon: gcj02Pt.longitude)
    }
    
    func gcj02ToBd09(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return bd09Encrypt(ggLat: location.latitude, ggLon: location.longitude)
    }
    
    func bd09ToGcj02(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return bd09Decrypt(bdLat: location.latitude, bdLon: location.longitude)
    }
    
    func bd09ToWgs84(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let gcj02:CLLocationCoordinate2D = bd09ToGcj02(location:location)
        return gcj02Decrypt(gjLat: gcj02.latitude, gjLon: gcj02.longitude)
    }
}

extension JanyLocationConverter{
    
    //MARK: LAT
    func LAT_OFFSET_0(x:Double,y:Double) -> Double {
        return -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
    }
    
    func LAT_OFFSET_1(x:Double) -> Double {
        return (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
    }
    
    func LAT_OFFSET_2(y:Double) -> Double {
        return (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
    }
    
    func LAT_OFFSET_3(y:Double) -> Double {
        return (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0
    }
    
    //MARK: LOT
    func LON_OFFSET_0(x:Double,y:Double) -> Double {
        return 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
    }
    
    func LON_OFFSET_1(x:Double) -> Double {
        return (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
    }
    
    func LON_OFFSET_2(x:Double) -> Double {
        return (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
    }
    
    func LON_OFFSET_3(x:Double) -> Double {
        return (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0
    }
    
    //MARK: convert
    func transformLat(x:Double,y:Double) -> Double {
        
        var ret:Double = LAT_OFFSET_0(x: x, y: y)
        
        ret += LAT_OFFSET_1(x: x)
        ret += LAT_OFFSET_2(y: y)
        ret += LAT_OFFSET_3(y: y)
        
        return ret
    }
    
    func transformLon(x:Double,y:Double) -> Double {
        
        var ret:Double = LON_OFFSET_0(x: x, y: y)
        
        ret += LON_OFFSET_1(x: x)
        ret += LON_OFFSET_2(x: x)
        ret += LON_OFFSET_3(x: x)
        
        return ret
    }
    
    func outOfChina(lat:Double,lon:Double) -> Bool {
        if lon < RANGE_LON_MIN || lon > RANGE_LON_MAX {
            return true
        }
        
        if lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX {
            return false
        }
        
        return false
    }
    
    func gcj02Encrypt(ggLat:Double,ggLon:Double) -> CLLocationCoordinate2D {
        
        var resPoint:CLLocationCoordinate2D = CLLocationCoordinate2D()
        var mgLat:Double
        var mgLon:Double
        
        if outOfChina(lat: ggLat, lon: ggLon) {
            resPoint.latitude = ggLat
            resPoint.longitude = ggLon
            return resPoint
        }
        
        var dLat:Double = transformLat(x: ggLon - 105.0, y: ggLon - 105.0)
        var dLon:Double = transformLon(x: ggLon - 105.0, y: ggLon - 105.0)
        
        let radLat:Double = ggLat / 180.0 * Double.pi
        
        var magic:Double = sin(radLat)
        magic = 1 - jzEE * magic * magic
        
        let sqrtMagic:Double = sqrt(magic)
        
        dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * Double.pi)
        dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * Double.pi)
        mgLat = ggLat + dLat
        mgLon = ggLon + dLon
        
        resPoint.latitude = mgLat
        resPoint.longitude = mgLon
        
        return resPoint
    }
    
    func gcj02Decrypt(gjLat:Double,gjLon:Double) -> CLLocationCoordinate2D {
        
        let gpt:CLLocationCoordinate2D = gcj02Encrypt(ggLat: gjLat, ggLon: gjLon)
        
        let dLon:Double = gpt.longitude - gjLon
        let dLat:Double = gpt.latitude - gjLat
        
        var pt:CLLocationCoordinate2D = CLLocationCoordinate2D()
        pt.latitude = gjLat - dLat
        pt.longitude = gjLon - dLon
        
        return pt
    }
    
    func bd09Decrypt(bdLat:Double,bdLon:Double) -> CLLocationCoordinate2D {
        
        var gcjPt:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let x:Double = bdLon - 0.0065, y = bdLat - 0.006
        let z:Double = sqrt(x * x + y * y) - 0.00002 * sin(y * Double.pi)
        let theta:Double = atan2(y, x) - 0.000003 * cos(x * Double.pi)
        
        gcjPt.longitude = z * cos(theta);
        gcjPt.latitude = z * sin(theta);
        
        return gcjPt
    }
    
    func bd09Encrypt(ggLat:Double,ggLon:Double) -> CLLocationCoordinate2D {
        
        var bdPt:CLLocationCoordinate2D = CLLocationCoordinate2D()
        let x:Double = ggLon, y = ggLat
        let z:Double = sqrt(x * x + y * y) - 0.00002 * sin(y * Double.pi)
        let theta:Double = atan2(y, x) + 0.000003 * cos(x * Double.pi)
        
        bdPt.longitude = z * cos(theta) + 0.0065
        bdPt.latitude = z * sin(theta) + 0.006
        
        return bdPt
    }
}
