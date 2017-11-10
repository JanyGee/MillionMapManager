//
//  MapView.swift
//  Example
//
//  Created by Jany on 2017/11/10.
//  Copyright © 2017年 MillionConcept. All rights reserved.
//

import UIKit
import GoogleMaps

enum MapDisplayType {//常规地图、卫星地图、3D地图
    case MapNormal
    case MapSatellite
    case Map3D
}
enum Coordinate2DType {
    case Wgs84//世界标准地理坐标
    case Gcj02//中国国测局地理坐标（GCJ-02）<火星坐标>
    case Bd09//百度地理坐标（BD-09)
}
class MapView: UIView,GMSMapViewDelegate {
    
    private lazy var myMap:GMSMapView = GMSMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapView{
    
    //MARK: setupMap
    func setUpUI() -> Void {
        addSubview(myMap)
        myMap.frame = bounds
        myMap.mapType = .normal
        myMap.delegate = self
        myMap.setMinZoom(0, maxZoom: 50)
    }
}
