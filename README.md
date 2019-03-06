# RxSportEquipement

RxSportEquipement is a Swift example project that search for sport equipements in Lyon (France) according user's location from the OpenDataSoft API.

It simulates a user's movements from a `GPX` file, the perimeter of the search area can vary between 0 and 10 kilometers according the `UISlider` value.

# Architecture

Project is using `RxSwift` and `RxCocoa` under the `MVVM` architecture and dependancies injection from `Swinject`.

- `MapView`
- `CoreLocation`
- `SwinjectStoryboard`

OpenDataSoft API : https://public.opendatasoft.com/api/v1/console/datasets/1.0/search/


