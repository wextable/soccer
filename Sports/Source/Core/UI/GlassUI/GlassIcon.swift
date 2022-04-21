//
//  GlassIcon.swift
//  GlassUI
//
//  Created by Owen Pierce on 4/17/20.
//  Copyright © 2020 Walmart. All rights reserved.
//

import SwiftUI
import UIKit

/// Collection of icons as defined in style sheet.
///
/// - Note: GlassIcon images are rendered as `alwaysOriginal`. To change the color of an image, call
///  `withRenderingMode(.alwaysTemplate)` method on `image` and set the `tintColor` on the corresponding view.
///
/// Usage
/// ```swift
///  imageView.image = GlassIcon.addToCart.image(.size24).withRenderingMode(.alwaysTemplate)
///  imageView.tintColor = CoreColor.pink
/// ```
// swiftlint:disable type_body_length file_length
public enum GlassIcon: CaseIterable {
    case apparel
    case appleCare
    case arrowLeft
    case arrowRight
    case arrowUpLeft
    case article
    case auto
    case autoMoney
    case bag
    case balloon
    case ban
    case bandaid
    case bead
    case bell
    case birthdayCake
    case blueRay
    case book
    case bottle
    case bottleArrowRight
    case bottleFour
    case bottlePlus
    case bottleRefill
    case box
    case boxFedEx
    case boxReturn
    case butterCream
    case calendar
    case calendarMoney
    case camera
    case caretDown
    case caretUp
    case cart
    case cartArrowDown
    case cartFill
    case cartScan
    case category
    case champagne
    case chatBubble
    case check
    case checkCircle
    case checkCircleFill
    case chevronDown
    case chevronLeft
    case chevronRight
    case chevronUp
    case clock
    case close
    case cloudDownload
    case cloudUpload
    case cog
    case coldFood
    case coupon
    case creditCard
    case creditCardAmex
    case creditCardDiscover
    case creditCardDiscoverBlack
    case creditCardMastercard
    case creditCardSmcapitalmc
    case creditCardSmgemastercard
    case creditCardSmgestorecard
    case creditCardSpark
    case creditCardVisa
    case creditCardWmcapitalone
    case crop
    case currency
    case dVD
    case dimensions
    case direction
    case eBook
    case exclamationCircle
    case exclamationCircleFill
    case explore
    case exploreFill
    case externalLink
    case eye
    case eyeSlash
    case facebook
    case filter
    case flag
    case flash
    case flashSlash
    case flower
    case forkKnife
    case fuel
    case gasPump
    case gift
    case giftCard
    case giftCardSpark
    case giftCardOtcBenefit
    case giftCardOtherBenefit
    case globe
    case google
    case graduate
    case grid
    case gridFill
    case hairSalon
    case headphones
    case heart
    case heartFill
    case height
    case history
    case home
    case homeMoney
    case homeWrench
    case hotFood
    case icingBag
    case infoCircle
    case instagram
    case instawatch
    case keyboard
    case laptop
    case lightBulb
    case location
    case locationPlus
    case lock
    case lockOpen
    case magazine
    case mail
    case mapStore
    case marble
    case marketplace
    case medal
    case membership
    case menu
    case message
    case microphone
    case microphoneSlash
    case minus
    case mobileDevice
    case mobileDeviceRepair
    case moneyCircle
    case moneyCircleFill
    case more
    case muffin
    case myItems
    case nailSalon
    case note
    case onesie
    case pause
    case payBill
    case pencil
    case phone
    case photo
    case piggyBank
    case pinterest
    case plane
    case playCircle
    case plus
    case prescription
    case printer
    case promoCoupon
    case proSeller
    case qRCode
    case questionCircle
    case receipt
    case receiveMoney
    case remove
    case reorder
    case reorderFill
    case restroom
    case rocket
    case rocketAlt
    case rollback
    case rotate360
    case rugMaterial
    case rugWeave
    case sandwich
    case scanAndGo
    case scanBarCode
    case scanBottle
    case scanCamera
    case scanSpark
    case search
    case sendMoney
    case services
    case servicesFill
    case share
    case shell
    case shellAlt
    case shieldLines
    case shieldProtect
    case shieldSpark
    case shoppingBag
    case shuffle
    case signIn
    case signOut
    case snowflake
    case spark
    case sparkBlue
    case sparkle
    case sprinkles
    case star
    case starFill
    case starHalf
    case store
    case storeClock
    case storeFill
    case storeLocation
    case subscription
    case tires
    case thumbDown
    case thumbUp
    case trash
    case trophy
    case truck
    case twitter
    case user
    case userPlus
    case userSpark
    case vOD
    case vudu
    case wallet
    case walmartPay
    case walmartPlus
    case walmartPlusColor
    case walmartPlusWhite
    case warning
    case weeklyAd
    case whippedCream
    case wifi
    case wrench
    case yellowWarning
    case youtube
    case zoomIn
    case zoomOut

    public var name: String {
        switch self {
        case .apparel: return "Apparel"
        case .appleCare: return "AppleCare"
        case .arrowLeft: return "ArrowLeft"
        case .arrowRight: return "ArrowRight"
        case .arrowUpLeft: return "ArrowUpLeft"
        case .article: return "Article"
        case .auto: return "Auto"
        case .autoMoney: return "AutoMoney"
        case .bag: return "Bag"
        case .balloon: return "Balloon"
        case .ban: return "Ban"
        case .bandaid: return "Bandaid"
        case .bead: return "Bead"
        case .bell: return "Bell"
        case .birthdayCake: return "BirthdayCake"
        case .blueRay: return "BlueRay"
        case .book: return "Book"
        case .bottle: return "Bottle"
        case .bottleArrowRight: return "BottleArrowRight"
        case .bottleFour: return "BottleFour"
        case .bottlePlus: return "BottlePlus"
        case .bottleRefill: return "BottleRefill"
        case .box: return "Box"
        case .boxFedEx: return "BoxFedEx"
        case .boxReturn: return "BoxReturn"
        case .butterCream: return "ButterCream"
        case .calendar: return "Calendar"
        case .calendarMoney: return "CalendarMoney"
        case .camera: return "Camera"
        case .caretDown: return "CaretDown"
        case .caretUp: return "CaretUp"
        case .cart: return "Cart"
        case .cartArrowDown: return "CartArrowDown"
        case .cartFill: return "CartFill"
        case .cartScan: return "CartScan"
        case .category: return "Category"
        case .champagne: return "Champagne"
        case .chatBubble: return "ChatBubble"
        case .check: return "Check"
        case .checkCircle: return "CheckCircle"
        case .checkCircleFill: return "CheckCircleFill"
        case .chevronDown: return "ChevronDown"
        case .chevronLeft: return "ChevronLeft"
        case .chevronRight: return "ChevronRight"
        case .chevronUp: return "ChevronUp"
        case .clock: return "Clock"
        case .close: return "Close"
        case .cloudDownload: return "CloudDownload"
        case .cloudUpload: return "CloudUpload"
        case .cog: return "Cog"
        case .coldFood: return "ColdFood"
        case .coupon: return "Coupon"
        case .creditCard: return "CreditCard"
        case .creditCardAmex: return "CreditCardAmex"
        case .creditCardDiscover: return "CreditCardDiscover"
        case .creditCardDiscoverBlack: return "CreditCardDiscoverBlack"
        case .creditCardMastercard: return "CreditCardMastercard"
        case .creditCardSmcapitalmc: return "CreditCardSmcapitalmc"
        case .creditCardSmgemastercard: return "CreditCardSmgemastercard"
        case .creditCardSmgestorecard: return "CreditCardSmgestorecard"
        case .creditCardSpark: return "CreditCardSpark"
        case .creditCardVisa: return "CreditCardVisa"
        case .creditCardWmcapitalone: return "CreditCardWmcapitalone"
        case .crop: return "Crop"
        case .currency: return "Currency"
        case .dVD: return "DVD"
        case .dimensions: return "Dimensions"
        case .direction: return "Direction"
        case .eBook: return "EBook"
        case .exclamationCircle: return "ExclamationCircle"
        case .exclamationCircleFill: return "ExclamationCircleFill"
        case .explore: return "Explore"
        case .exploreFill: return "ExploreFill"
        case .externalLink: return "ExternalLink"
        case .eye: return "Eye"
        case .eyeSlash: return "EyeSlash"
        case .facebook: return "Facebook"
        case .filter: return "Filter"
        case .flag: return "Flag"
        case .flash: return "Flash"
        case .flashSlash: return "FlashSlash"
        case .flower: return "Flower"
        case .forkKnife: return "ForkKnife"
        case .fuel: return "Fuel"
        case .gasPump: return "GasPump"
        case .gift: return "Gift"
        case .giftCard: return "GiftCard"
        case .giftCardOtcBenefit: return "GiftCardOtcBenefit"
        case .giftCardOtherBenefit: return "GiftCardOtherBenefit"
        case .giftCardSpark: return "GiftCardSpark"
        case .globe: return "Globe"
        case .google: return "Google"
        case .graduate: return "Graduate"
        case .grid: return "Grid"
        case .gridFill: return "GridFill"
        case .hairSalon: return "HairSalon"
        case .headphones: return "Headphones"
        case .heart: return "Heart"
        case .heartFill: return "HeartFill"
        case .height: return "Height"
        case .history: return "History"
        case .home: return "Home"
        case .homeMoney: return "HomeMoney"
        case .homeWrench: return "HomeWrench"
        case .hotFood: return "HotFood"
        case .icingBag: return "IcingBag"
        case .infoCircle: return "InfoCircle"
        case .instagram: return "Instagram"
        case .instawatch: return "Instawatch"
        case .keyboard: return "Keyboard"
        case .laptop: return "Laptop"
        case .lightBulb: return "LightBulb"
        case .location: return "Location"
        case .locationPlus: return "LocationPlus"
        case .lock: return "Lock"
        case .lockOpen: return "LockOpen"
        case .magazine: return "Magazine"
        case .mail: return "Mail"
        case .mapStore: return "MapStore"
        case .marble: return "Marble"
        case .marketplace: return "Marketplace"
        case .medal: return "Medal"
        case .membership: return "Membership"
        case .menu: return "Menu"
        case .message: return "Message"
        case .microphone: return "Microphone"
        case .microphoneSlash: return "MicrophoneSlash"
        case .minus: return "Minus"
        case .mobileDevice: return "MobileDevice"
        case .mobileDeviceRepair: return "MobileDeviceRepair"
        case .moneyCircle: return "MoneyCircle"
        case .moneyCircleFill: return "MoneyCircleFill"
        case .more: return "More"
        case .muffin: return "Muffin"
        case .myItems: return "MyItems"
        case .nailSalon: return "NailSalon"
        case .note: return "Note"
        case .onesie: return "Onesie"
        case .pause: return "Pause"
        case .payBill: return "PayBill"
        case .pencil: return "Pencil"
        case .phone: return "Phone"
        case .photo: return "Photo"
        case .piggyBank: return "PiggyBank"
        case .pinterest: return "Pinterest"
        case .plane: return "Plane"
        case .playCircle: return "PlayCircle"
        case .plus: return "Plus"
        case .prescription: return "Prescription"
        case .printer: return "Printer"
        case .promoCoupon: return "PromoCoupon"
        case .proSeller: return "ProSeller"
        case .qRCode: return "QRCode"
        case .questionCircle: return "QuestionCircle"
        case .receipt: return "Receipt"
        case .receiveMoney: return "ReceiveMoney"
        case .remove: return "Remove"
        case .reorder: return "Reorder"
        case .reorderFill: return "ReorderFill"
        case .restroom: return "Restroom"
        case .rocket: return "Rocket"
        case .rocketAlt: return "RocketAlt"
        case .rollback: return "Rollback"
        case .rotate360: return "Rotate360"
        case .rugMaterial: return "RugMaterial"
        case .rugWeave: return "RugWeave"
        case .sandwich: return "Sandwich"
        case .scanAndGo: return "ScanAndGo"
        case .scanBarCode: return "ScanBarCode"
        case .scanBottle: return "ScanBottle"
        case .scanCamera: return "ScanCamera"
        case .scanSpark: return "ScanSpark"
        case .search: return "Search"
        case .sendMoney: return "SendMoney"
        case .services: return "Services"
        case .servicesFill: return "ServicesFill"
        case .share: return "Share"
        case .shell: return "Shell"
        case .shellAlt: return "ShellAlt"
        case .shieldLines: return "ShieldLines"
        case .shieldProtect: return "ShieldProtect"
        case .shieldSpark: return "ShieldSpark"
        case .shoppingBag: return "ShoppingBag"
        case .shuffle: return "Shuffle"
        case .signIn: return "SignIn"
        case .signOut: return "SignOut"
        case .snowflake: return "Snowflake"
        case .spark: return "Spark"
        case .sparkBlue: return "SparkBlue"
        case .sparkle: return "Sparkle"
        case .sprinkles: return "Sprinkles"
        case .star: return "Star"
        case .starFill: return "StarFill"
        case .starHalf: return "StarHalf"
        case .store: return "Store"
        case .storeClock: return "StoreClock"
        case .storeFill: return "StoreFill"
        case .storeLocation: return "StoreLocation"
        case .subscription: return "Subscription"
        case .tires: return "Tires"
        case .thumbDown: return "ThumbDown"
        case .thumbUp: return "ThumbUp"
        case .trash: return "Trash"
        case .trophy: return "Trophy"
        case .truck: return "Truck"
        case .twitter: return "Twitter"
        case .user: return "User"
        case .userPlus: return "UserPlus"
        case .userSpark: return "UserSpark"
        case .vOD: return "VOD"
        case .vudu: return "Vudu"
        case .wallet: return "Wallet"
        case .walmartPay: return "WalmartPay"
        case .walmartPlus: return "WalmartPlus"
        case .walmartPlusColor: return "WalmartPlusColor"
        case .walmartPlusWhite: return "WalmartPlusWhite"
        case .warning: return "Warning"
        case .weeklyAd: return "WeeklyAd"
        case .whippedCream: return "WhippedCream"
        case .wifi: return "Wifi"
        case .wrench: return "Wrench"
        case .yellowWarning: return "YellowWarning"
        case .youtube: return "Youtube"
        case .zoomIn: return "ZoomIn"
        case .zoomOut: return "ZoomOut"
        }
    }

    public var iconAccessibilityLabel: String {
        switch self {
        case .apparel: return "apparel".localize()
        case .appleCare: return "apple care".localize()
        case .arrowLeft: return "arrowLeft".localize()
        case .arrowRight: return "arrowRight".localize()
        case .arrowUpLeft: return "arrowUpLeft".localize()
        case .article: return "article".localize()
        case .auto: return "auto".localize()
        case .autoMoney: return "autoMoney".localize()
        case .bag: return "bag".localize()
        case .balloon: return "balloon".localize()
        case .ban: return "ban".localize()
        case .bandaid: return "bandaid".localize()
        case .bead: return "bead".localize()
        case .bell: return "bell".localize()
        case .birthdayCake: return "birthdayCake".localize()
        case .blueRay: return "blueRay".localize()
        case .book: return "book".localize()
        case .bottle: return "bottle".localize()
        case .bottleArrowRight: return "bottleArrowRight".localize()
        case .bottleFour: return "bottleFour".localize()
        case .bottlePlus: return "bottlePlus".localize()
        case .bottleRefill: return "bottleRefill".localize()
        case .box: return "box".localize()
        case .boxFedEx: return "boxFedEx".localize()
        case .boxReturn: return "boxReturn".localize()
        case .butterCream: return "butterCream".localize()
        case .calendar: return "calendar".localize()
        case .calendarMoney: return "calendarMoney".localize()
        case .camera: return "camera".localize()
        case .caretDown: return "caretDown".localize()
        case .caretUp: return "caretUp".localize()
        case .cart: return "cart".localize()
        case .cartArrowDown: return "cartArrowDown".localize()
        case .cartFill: return "cartFill".localize()
        case .cartScan: return "cartScan".localize()
        case .category: return "category".localize()
        case .champagne: return "champagne".localize()
        case .chatBubble: return "chatBubble".localize()
        case .check: return "check".localize()
        case .checkCircle: return "checkCircle".localize()
        case .checkCircleFill: return "checkCircleFill".localize()
        case .chevronDown: return "chevronDown".localize()
        case .chevronLeft: return "chevronLeft".localize()
        case .chevronRight: return "chevronRight".localize()
        case .chevronUp: return "chevronUp".localize()
        case .clock: return "clock".localize()
        case .close: return "close".localize()
        case .cloudDownload: return "cloudDownload".localize()
        case .cloudUpload: return "cloudUpload".localize()
        case .cog: return "cog".localize()
        case .coldFood: return "coldFood".localize()
        case .coupon: return "coupon".localize()
        case .creditCard: return "creditCard".localize()
        case .creditCardAmex: return "creditCardAmex".localize()
        case .creditCardDiscover: return "creditCardDiscover".localize()
        case .creditCardDiscoverBlack: return "creditCardDiscoverBlack".localize()
        case .creditCardMastercard: return "creditCardMastercard".localize()
        case .creditCardSmcapitalmc: return "creditCardSmcapitalmc".localize()
        case .creditCardSmgemastercard: return "creditCardSmgemastercard".localize()
        case .creditCardSmgestorecard: return "creditCardSmgestorecard".localize()
        case .creditCardSpark: return "creditCardSpark".localize()
        case .creditCardVisa: return "creditCardVisa".localize()
        case .creditCardWmcapitalone: return "creditCardWmcapitalone".localize()
        case .crop: return "crop".localize()
        case .currency: return "currency".localize()
        case .dVD: return "dVD".localize()
        case .dimensions: return "dimensions".localize()
        case .direction: return "direction".localize()
        case .eBook: return "eBook".localize()
        case .exclamationCircle: return "exclamationCircle".localize()
        case .exclamationCircleFill: return "exclamationCircleFill".localize()
        case .explore: return "explore".localize()
        case .exploreFill: return "exploreFill".localize()
        case .externalLink: return "externalLink".localize()
        case .eye: return "eye".localize()
        case .eyeSlash: return "eyeSlash".localize()
        case .facebook: return "facebook".localize()
        case .filter: return "filter".localize()
        case .flag: return "flag".localize()
        case .flash: return "flash".localize()
        case .flashSlash: return "flashSlash".localize()
        case .flower: return "flower".localize()
        case .forkKnife: return "forkKnife".localize()
        case .fuel: return "fuel".localize()
        case .gasPump: return "gasPump".localize()
        case .gift: return "gift".localize()
        case .giftCard: return "giftCard".localize()
        case .giftCardOtcBenefit: return "giftCardOtcBenefit".localize()
        case .giftCardOtherBenefit: return "giftCardOtherBenefit".localize()
        case .giftCardSpark: return "giftCardSpark".localize()
        case .globe: return "globe".localize()
        case .google: return "google".localize()
        case .graduate: return "graduate".localize()
        case .grid: return "grid".localize()
        case .gridFill: return "gridFill".localize()
        case .hairSalon: return "hairSalon".localize()
        case .headphones: return "headphones".localize()
        case .heart: return "heart".localize()
        case .heartFill: return "heartFill".localize()
        case .height: return "height".localize()
        case .history: return "history".localize()
        case .home: return "home".localize()
        case .homeMoney: return "homeMoney".localize()
        case .homeWrench: return "homeWrench".localize()
        case .hotFood: return "hotFood".localize()
        case .icingBag: return "icingBag".localize()
        case .infoCircle: return "infoCircle".localize()
        case .instagram: return "instagram".localize()
        case .instawatch: return "instawatch".localize()
        case .keyboard: return "keyboard".localize()
        case .laptop: return "laptop".localize()
        case .lightBulb: return "lightBulb".localize()
        case .location: return "location".localize()
        case .locationPlus: return "locationPlus".localize()
        case .lock: return "lock".localize()
        case .lockOpen: return "lockOpen".localize()
        case .magazine: return "magazine".localize()
        case .mail: return "mail".localize()
        case .mapStore: return "mapStore".localize()
        case .marble: return "marble".localize()
        case .marketplace: return "marketplace".localize()
        case .medal: return "medal".localize()
        case .membership: return "membership".localize()
        case .menu: return "menu".localize()
        case .message: return "message".localize()
        case .microphone: return "microphone".localize()
        case .microphoneSlash: return "microphoneSlash".localize()
        case .minus: return "minus".localize()
        case .mobileDevice: return "mobileDevice".localize()
        case .mobileDeviceRepair: return "mobileDeviceRepair".localize()
        case .moneyCircle: return "moneyCircle".localize()
        case .moneyCircleFill: return "moneyCircleFill".localize()
        case .more: return "more".localize()
        case .muffin: return "muffin".localize()
        case .myItems: return "myItems".localize()
        case .nailSalon: return "nailSalon".localize()
        case .note: return "note".localize()
        case .onesie: return "onesie".localize()
        case .pause: return "pause".localize()
        case .payBill: return "payBill".localize()
        case .pencil: return "pencil".localize()
        case .phone: return "phone".localize()
        case .photo: return "photo".localize()
        case .piggyBank: return "piggyBank".localize()
        case .pinterest: return "pinterest".localize()
        case .plane: return "plane".localize()
        case .playCircle: return "playCircle".localize()
        case .plus: return "Add to Cart".localize()
        case .prescription: return "prescription".localize()
        case .printer: return "printer".localize()
        case .promoCoupon: return "promoCoupon".localize()
        case .proSeller: return "proSeller".localize()
        case .qRCode: return "qRCode".localize()
        case .questionCircle: return "questionCircle".localize()
        case .receipt: return "receipt".localize()
        case .receiveMoney: return "receiveMoney".localize()
        case .remove: return "remove".localize()
        case .reorder: return "reorder".localize()
        case .reorderFill: return "reorderFill".localize()
        case .restroom: return "restroom".localize()
        case .rocket: return "rocket".localize()
        case .rocketAlt: return "rocketAlt".localize()
        case .rollback: return "rollback".localize()
        case .rotate360: return "rotate360".localize()
        case .rugMaterial: return "rugMaterial".localize()
        case .rugWeave: return "rugWeave".localize()
        case .sandwich: return "sandwich".localize()
        case .scanAndGo: return "Scan and Go".localize()
        case .scanBarCode: return "scanBarCode".localize()
        case .scanBottle: return "scanBottle".localize()
        case .scanCamera: return "scanCamera".localize()
        case .scanSpark: return "scanSpark".localize()
        case .search: return "search".localize()
        case .sendMoney: return "sendMoney".localize()
        case .services: return "services".localize()
        case .servicesFill: return "servicesFill".localize()
        case .share: return "share".localize()
        case .shell: return "shell".localize()
        case .shellAlt: return "shellAlt".localize()
        case .shieldLines: return "shieldLines".localize()
        case .shieldProtect: return "shieldProtect".localize()
        case .shieldSpark: return "shieldSpark".localize()
        case .shoppingBag: return "shoppingBag".localize()
        case .shuffle: return "shuffle".localize()
        case .signIn: return "signIn".localize()
        case .signOut: return "signOut".localize()
        case .snowflake: return "snowflake".localize()
        case .spark: return "spark".localize()
        case .sparkBlue: return "sparkBlue".localize()
        case .sparkle: return "sparkle".localize()
        case .sprinkles: return "sprinkles".localize()
        case .star: return "star".localize()
        case .starFill: return "starFill".localize()
        case .starHalf: return "starHalf".localize()
        case .store: return "store".localize()
        case .storeClock: return "storeClock".localize()
        case .storeFill: return "storeFill".localize()
        case .storeLocation: return "storeLocation".localize()
        case .subscription: return "Subscription".localize()
        case .tires: return "tires".localize()
        case .thumbDown: return "thumbDown".localize()
        case .thumbUp: return "thumbUp".localize()
        case .trash: return "trash".localize()
        case .trophy: return "trophy".localize()
        case .truck: return "truck".localize()
        case .twitter: return "twitter".localize()
        case .user: return "user".localize()
        case .userPlus: return "userPlus".localize()
        case .userSpark: return "userSpark".localize()
        case .vOD: return "vOD".localize()
        case .vudu: return "vudu".localize()
        case .wallet: return "wallet".localize()
        case .walmartPay: return "walmartPay".localize()
        case .walmartPlus: return "walmartPlus".localize()
        case .walmartPlusColor: return "walmartPlus".localize()
        case .walmartPlusWhite: return "walmartPlus".localize()
        case .warning: return "warning".localize()
        case .weeklyAd: return "weeklyAd".localize()
        case .whippedCream: return "whippedCream".localize()
        case .wifi: return "wifi".localize()
        case .wrench: return "wrench".localize()
        case .yellowWarning: return "yellowWarning".localize()
        case .youtube: return "youtube".localize()
        case .zoomIn: return "zoomIn".localize()
        case .zoomOut: return "zoomOut".localize()
        }
    }

    public var isSymbol: Bool {
        switch self {
        case .apparel,
             .appleCare,
             .arrowLeft,
             .arrowRight,
             .arrowUpLeft,
             .article,
             .auto,
             .autoMoney,
             .bag,
             .balloon,
             .ban,
             .bandaid,
             .bead,
             .bell,
             .birthdayCake,
             .blueRay,
             .book,
             .bottle,
             .bottleArrowRight,
             .bottleFour,
             .bottlePlus,
             .bottleRefill,
             .box,
             .boxFedEx,
             .boxReturn,
             .butterCream,
             .calendar,
             .calendarMoney,
             .camera,
             .caretDown,
             .caretUp,
             .cart,
             .cartArrowDown,
             .cartFill,
             .cartScan,
             .category,
             .champagne,
             .chatBubble,
             .check,
             .checkCircle,
             .checkCircleFill,
             .chevronDown,
             .chevronLeft,
             .chevronRight,
             .chevronUp,
             .clock,
             .close,
             .cloudDownload,
             .cloudUpload,
             .cog,
             .coldFood,
             .coupon,
             .creditCard,
             .creditCardSpark,
             .crop,
             .currency,
             .dVD,
             .dimensions,
             .direction,
             .eBook,
             .exclamationCircle,
             .exclamationCircleFill,
             .explore,
             .exploreFill,
             .externalLink,
             .eye,
             .eyeSlash,
             .facebook,
             .filter,
             .flag,
             .flash,
             .flashSlash,
             .flower,
             .forkKnife,
             .fuel,
             .gasPump,
             .gift,
             .giftCard,
             .giftCardSpark,
             .globe,
             .google,
             .graduate,
             .grid,
             .gridFill,
             .hairSalon,
             .headphones,
             .heart,
             .heartFill,
             .height,
             .history,
             .home,
             .homeMoney,
             .homeWrench,
             .hotFood,
             .icingBag,
             .infoCircle,
             .instagram,
             .instawatch,
             .keyboard,
             .laptop,
             .lightBulb,
             .location,
             .locationPlus,
             .lock,
             .lockOpen,
             .magazine,
             .mail,
             .mapStore,
             .marble,
             .marketplace,
             .medal,
             .membership,
             .menu,
             .message,
             .microphone,
             .microphoneSlash,
             .minus,
             .mobileDevice,
             .mobileDeviceRepair,
             .moneyCircle,
             .moneyCircleFill,
             .more,
             .muffin,
             .myItems,
             .nailSalon,
             .note,
             .onesie,
             .pause,
             .payBill,
             .pencil,
             .phone,
             .photo,
             .piggyBank,
             .pinterest,
             .plane,
             .playCircle,
             .plus,
             .prescription,
             .printer,
             .promoCoupon,
             .proSeller,
             .qRCode,
             .questionCircle,
             .receipt,
             .receiveMoney,
             .remove,
             .reorder,
             .reorderFill,
             .restroom,
             .rocket,
             .rocketAlt,
             .rollback,
             .rotate360,
             .rugMaterial,
             .rugWeave,
             .sandwich,
             .scanAndGo,
             .scanBarCode,
             .scanBottle,
             .scanCamera,
             .scanSpark,
             .search,
             .sendMoney,
             .services,
             .servicesFill,
             .share,
             .shell,
             .shellAlt,
             .shieldLines,
             .shieldProtect,
             .shieldSpark,
             .shoppingBag,
             .shuffle,
             .signIn,
             .signOut,
             .snowflake,
             .spark,
             .sparkBlue,
             .sparkle,
             .sprinkles,
             .star,
             .starFill,
             .starHalf,
             .store,
             .storeClock,
             .storeFill,
             .storeLocation,
             .subscription,
             .tires,
             .thumbDown,
             .thumbUp,
             .trash,
             .trophy,
             .truck,
             .twitter,
             .user,
             .userPlus,
             .userSpark,
             .vOD,
             .vudu,
             .wallet,
             .walmartPay,
             .walmartPlus,
             .walmartPlusColor,
             .walmartPlusWhite,
             .warning,
             .weeklyAd,
             .whippedCream,
             .wifi,
             .wrench,
             .yellowWarning,
             .youtube,
             .zoomIn,
             .zoomOut:
            return true
        case .creditCardAmex,
             .creditCardDiscover,
             .creditCardDiscoverBlack,
             .creditCardMastercard,
             .creditCardSmcapitalmc,
             .creditCardSmgemastercard,
             .creditCardSmgestorecard,
             .creditCardVisa,
             .creditCardWmcapitalone,
             .giftCardOtcBenefit,
             .giftCardOtherBenefit:
            return false
        }
    }

    private static var imageCache = NSCache<NSString, UIImage>()
}

extension GlassIcon {
    /// Returns the `GlassIcon` as a SwiftUI image.
    public var swiftUIImage: Image {
        let image = Image.coreImage(named: assetName, bundle: nil)
        return image
            .accessibility(label: Text(iconAccessibilityLabel))
            .content
            .renderingMode(.original)
    }

    /// Returns the `GlassIcon` as an image.
    public var image: UIImage {
        let image = UIImage.coreImage(named: assetName, bundle: nil)!.withRenderingMode(.alwaysOriginal)
        image.accessibilityLabel = iconAccessibilityLabel

        return image
    }

    private var assetName: String {
        return "icon-\(name)"
    }

    // MARK: - Sizing

    /// The standard icon sizes as defined in the style sheet.
    public enum Size: Equatable {
        case size12
        case size16
        case size24
        case size32
        case custom(CGFloat)

        public var cgSize: CGSize {
            switch self {
            case .size12: return GlassImageDimension.size12
            case .size16: return GlassImageDimension.size16
            case .size24: return GlassImageDimension.size24
            case .size32: return GlassImageDimension.size32
            case .custom(let dimension): return CGSize(width: dimension, height: dimension)
            }
        }
    }

    /// Returns the `GlassIcon` as a 12x12 image.
    public func imageSize12() -> UIImage? {
        return image(.size12)
    }

    /// Returns the `GlassIcon` as a 16x16 image.
    public func imageSize16() -> UIImage? {
        return image(.size16)
    }

    /// Returns the `GlassIcon` as a 24x24 image.
    public func imageSize24() -> UIImage? {
        return image(.size24)
    }

    /// Returns the `GlassIcon` as a 32x32 image.
    public func imageSize32() -> UIImage? {
        return image(.size32)
    }

    /// Resizes and returns the `GlassIcon` as an image.
    ///
    /// - Parameter size: the desired size of the icon
    /// - Returns: icon image
    public func image(_ size: Size) -> UIImage {
        return Self.getOrCreateIcon(self, for: size)
    }

    private func createImage(_ size: Size) -> UIImage {
        return image.resizedTo(targetSize: size.cgSize).withRenderingMode(.alwaysOriginal)
    }

    private static func getOrCreateIcon(_ icon: GlassIcon, for size: GlassIcon.Size) -> UIImage {
        let cacheKey = icon.name.appendingFormat("%.2f", size.cgSize.width) as NSString

        if let cached = imageCache.object(forKey: cacheKey) {
            return cached
        }
        let createdIcon = icon.createImage(size)
        imageCache.setObject(createdIcon, forKey: cacheKey)
        return createdIcon
    }
}

#if DEBUG

extension GlassIcon {
    struct TestHooks {
        func clearCache() {
            GlassIcon.imageCache.removeAllObjects()
        }

        func getCachedIcon(_ icon: GlassIcon, for size: GlassIcon.Size) -> UIImage? {
            let cacheKey = icon.name.appendingFormat("%.2f", size.cgSize.width) as NSString
            return GlassIcon.imageCache.object(forKey: cacheKey)
        }
    }
}

#endif
