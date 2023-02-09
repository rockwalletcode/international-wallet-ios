// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let blocksetLogoWhite = ImageAsset(name: "BlocksetLogoWhite")
  internal static let circleCheckSolid = ImageAsset(name: "CircleCheckSolid")
  internal static let cutoutFaceId = ImageAsset(name: "CutoutFaceId")
  internal static let delete = ImageAsset(name: "Delete")
  internal static let faceIdLarge = ImageAsset(name: "FaceId-Large")
  internal static let faceId = ImageAsset(name: "FaceId")
  internal static let flash = ImageAsset(name: "Flash")
  internal static let importIllustration = ImageAsset(name: "ImportIllustration")
  internal static let keychain = ImageAsset(name: "Keychain")
  internal static let leftArrow = ImageAsset(name: "LeftArrow")
  internal static let buy = ImageAsset(name: "buy")
  internal static let placemark = ImageAsset(name: "placemark")
  internal static let trade = ImageAsset(name: "trade")
  internal static let recoverWalletIllustration = ImageAsset(name: "RecoverWalletIllustration")
  internal static let deleteAlert = ImageAsset(name: "deleteAlert")
  internal static let avatar = ImageAsset(name: "avatar")
  internal static let ad = ImageAsset(name: "AD")
  internal static let ae = ImageAsset(name: "AE")
  internal static let af = ImageAsset(name: "AF")
  internal static let ag = ImageAsset(name: "AG")
  internal static let ai = ImageAsset(name: "AI")
  internal static let al = ImageAsset(name: "AL")
  internal static let am = ImageAsset(name: "AM")
  internal static let an = ImageAsset(name: "AN")
  internal static let ao = ImageAsset(name: "AO")
  internal static let ar = ImageAsset(name: "AR")
  internal static let `as` = ImageAsset(name: "AS")
  internal static let at = ImageAsset(name: "AT")
  internal static let au = ImageAsset(name: "AU")
  internal static let aw = ImageAsset(name: "AW")
  internal static let ax = ImageAsset(name: "AX")
  internal static let az = ImageAsset(name: "AZ")
  internal static let ba = ImageAsset(name: "BA")
  internal static let bb = ImageAsset(name: "BB")
  internal static let bd = ImageAsset(name: "BD")
  internal static let be = ImageAsset(name: "BE")
  internal static let bf = ImageAsset(name: "BF")
  internal static let bg = ImageAsset(name: "BG")
  internal static let bh = ImageAsset(name: "BH")
  internal static let bi = ImageAsset(name: "BI")
  internal static let bj = ImageAsset(name: "BJ")
  internal static let bl = ImageAsset(name: "BL")
  internal static let bm = ImageAsset(name: "BM")
  internal static let bn = ImageAsset(name: "BN")
  internal static let bo = ImageAsset(name: "BO")
  internal static let br = ImageAsset(name: "BR")
  internal static let bs = ImageAsset(name: "BS")
  internal static let bt = ImageAsset(name: "BT")
  internal static let bv = ImageAsset(name: "BV")
  internal static let bw = ImageAsset(name: "BW")
  internal static let by = ImageAsset(name: "BY")
  internal static let bz = ImageAsset(name: "BZ")
  internal static let ca = ImageAsset(name: "CA")
  internal static let cc = ImageAsset(name: "CC")
  internal static let cd = ImageAsset(name: "CD")
  internal static let cf = ImageAsset(name: "CF")
  internal static let cg = ImageAsset(name: "CG")
  internal static let ch = ImageAsset(name: "CH")
  internal static let ci = ImageAsset(name: "CI")
  internal static let ck = ImageAsset(name: "CK")
  internal static let cl = ImageAsset(name: "CL")
  internal static let cm = ImageAsset(name: "CM")
  internal static let cn = ImageAsset(name: "CN")
  internal static let co = ImageAsset(name: "CO")
  internal static let cr = ImageAsset(name: "CR")
  internal static let cu = ImageAsset(name: "CU")
  internal static let cv = ImageAsset(name: "CV")
  internal static let cw = ImageAsset(name: "CW")
  internal static let cx = ImageAsset(name: "CX")
  internal static let cy = ImageAsset(name: "CY")
  internal static let cz = ImageAsset(name: "CZ")
  internal static let de = ImageAsset(name: "DE")
  internal static let dj = ImageAsset(name: "DJ")
  internal static let dk = ImageAsset(name: "DK")
  internal static let dm = ImageAsset(name: "DM")
  internal static let `do` = ImageAsset(name: "DO")
  internal static let dz = ImageAsset(name: "DZ")
  internal static let ec = ImageAsset(name: "EC")
  internal static let ee = ImageAsset(name: "EE")
  internal static let eg = ImageAsset(name: "EG")
  internal static let er = ImageAsset(name: "ER")
  internal static let es = ImageAsset(name: "ES")
  internal static let et = ImageAsset(name: "ET")
  internal static let fi = ImageAsset(name: "FI")
  internal static let fj = ImageAsset(name: "FJ")
  internal static let fk = ImageAsset(name: "FK")
  internal static let fm = ImageAsset(name: "FM")
  internal static let fo = ImageAsset(name: "FO")
  internal static let fr = ImageAsset(name: "FR")
  internal static let ga = ImageAsset(name: "GA")
  internal static let gb = ImageAsset(name: "GB")
  internal static let gd = ImageAsset(name: "GD")
  internal static let ge = ImageAsset(name: "GE")
  internal static let gf = ImageAsset(name: "GF")
  internal static let gg = ImageAsset(name: "GG")
  internal static let gh = ImageAsset(name: "GH")
  internal static let gi = ImageAsset(name: "GI")
  internal static let gl = ImageAsset(name: "GL")
  internal static let gm = ImageAsset(name: "GM")
  internal static let gn = ImageAsset(name: "GN")
  internal static let gp = ImageAsset(name: "GP")
  internal static let gq = ImageAsset(name: "GQ")
  internal static let gr = ImageAsset(name: "GR")
  internal static let gt = ImageAsset(name: "GT")
  internal static let gu = ImageAsset(name: "GU")
  internal static let gw = ImageAsset(name: "GW")
  internal static let gy = ImageAsset(name: "GY")
  internal static let hk = ImageAsset(name: "HK")
  internal static let hn = ImageAsset(name: "HN")
  internal static let hr = ImageAsset(name: "HR")
  internal static let ht = ImageAsset(name: "HT")
  internal static let hu = ImageAsset(name: "HU")
  internal static let id = ImageAsset(name: "ID")
  internal static let ie = ImageAsset(name: "IE")
  internal static let il = ImageAsset(name: "IL")
  internal static let im = ImageAsset(name: "IM")
  internal static let `in` = ImageAsset(name: "IN")
  internal static let iq = ImageAsset(name: "IQ")
  internal static let ir = ImageAsset(name: "IR")
  internal static let `is` = ImageAsset(name: "IS")
  internal static let it = ImageAsset(name: "IT")
  internal static let je = ImageAsset(name: "JE")
  internal static let jm = ImageAsset(name: "JM")
  internal static let jo = ImageAsset(name: "JO")
  internal static let jp = ImageAsset(name: "JP")
  internal static let ke = ImageAsset(name: "KE")
  internal static let kg = ImageAsset(name: "KG")
  internal static let kh = ImageAsset(name: "KH")
  internal static let ki = ImageAsset(name: "KI")
  internal static let km = ImageAsset(name: "KM")
  internal static let kn = ImageAsset(name: "KN")
  internal static let kp = ImageAsset(name: "KP")
  internal static let kr = ImageAsset(name: "KR")
  internal static let kw = ImageAsset(name: "KW")
  internal static let ky = ImageAsset(name: "KY")
  internal static let kz = ImageAsset(name: "KZ")
  internal static let la = ImageAsset(name: "LA")
  internal static let lb = ImageAsset(name: "LB")
  internal static let lc = ImageAsset(name: "LC")
  internal static let li = ImageAsset(name: "LI")
  internal static let lk = ImageAsset(name: "LK")
  internal static let lr = ImageAsset(name: "LR")
  internal static let ls = ImageAsset(name: "LS")
  internal static let lt = ImageAsset(name: "LT")
  internal static let lu = ImageAsset(name: "LU")
  internal static let lv = ImageAsset(name: "LV")
  internal static let ly = ImageAsset(name: "LY")
  internal static let ma = ImageAsset(name: "MA")
  internal static let mc = ImageAsset(name: "MC")
  internal static let md = ImageAsset(name: "MD")
  internal static let me = ImageAsset(name: "ME")
  internal static let mf = ImageAsset(name: "MF")
  internal static let mg = ImageAsset(name: "MG")
  internal static let mh = ImageAsset(name: "MH")
  internal static let mk = ImageAsset(name: "MK")
  internal static let ml = ImageAsset(name: "ML")
  internal static let mm = ImageAsset(name: "MM")
  internal static let mn = ImageAsset(name: "MN")
  internal static let mp = ImageAsset(name: "MP")
  internal static let mq = ImageAsset(name: "MQ")
  internal static let mr = ImageAsset(name: "MR")
  internal static let ms = ImageAsset(name: "MS")
  internal static let mt = ImageAsset(name: "MT")
  internal static let mu = ImageAsset(name: "MU")
  internal static let mv = ImageAsset(name: "MV")
  internal static let mw = ImageAsset(name: "MW")
  internal static let mx = ImageAsset(name: "MX")
  internal static let my = ImageAsset(name: "MY")
  internal static let mz = ImageAsset(name: "MZ")
  internal static let na = ImageAsset(name: "NA")
  internal static let nc = ImageAsset(name: "NC")
  internal static let ne = ImageAsset(name: "NE")
  internal static let nf = ImageAsset(name: "NF")
  internal static let ng = ImageAsset(name: "NG")
  internal static let ni = ImageAsset(name: "NI")
  internal static let nl = ImageAsset(name: "NL")
  internal static let no = ImageAsset(name: "NO")
  internal static let np = ImageAsset(name: "NP")
  internal static let nr = ImageAsset(name: "NR")
  internal static let nz = ImageAsset(name: "NZ")
  internal static let om = ImageAsset(name: "OM")
  internal static let pa = ImageAsset(name: "PA")
  internal static let pe = ImageAsset(name: "PE")
  internal static let pf = ImageAsset(name: "PF")
  internal static let pg = ImageAsset(name: "PG")
  internal static let ph = ImageAsset(name: "PH")
  internal static let pk = ImageAsset(name: "PK")
  internal static let pl = ImageAsset(name: "PL")
  internal static let pm = ImageAsset(name: "PM")
  internal static let pr = ImageAsset(name: "PR")
  internal static let ps = ImageAsset(name: "PS")
  internal static let pt = ImageAsset(name: "PT")
  internal static let pw = ImageAsset(name: "PW")
  internal static let py = ImageAsset(name: "PY")
  internal static let qa = ImageAsset(name: "QA")
  internal static let ro = ImageAsset(name: "RO")
  internal static let rs = ImageAsset(name: "RS")
  internal static let ru = ImageAsset(name: "RU")
  internal static let rw = ImageAsset(name: "RW")
  internal static let sa = ImageAsset(name: "SA")
  internal static let sb = ImageAsset(name: "SB")
  internal static let sc = ImageAsset(name: "SC")
  internal static let sd = ImageAsset(name: "SD")
  internal static let se = ImageAsset(name: "SE")
  internal static let sg = ImageAsset(name: "SG")
  internal static let sh = ImageAsset(name: "SH")
  internal static let si = ImageAsset(name: "SI")
  internal static let sk = ImageAsset(name: "SK")
  internal static let sl = ImageAsset(name: "SL")
  internal static let sm = ImageAsset(name: "SM")
  internal static let sn = ImageAsset(name: "SN")
  internal static let so = ImageAsset(name: "SO")
  internal static let sr = ImageAsset(name: "SR")
  internal static let ss = ImageAsset(name: "SS")
  internal static let st = ImageAsset(name: "ST")
  internal static let sv = ImageAsset(name: "SV")
  internal static let sx = ImageAsset(name: "SX")
  internal static let sy = ImageAsset(name: "SY")
  internal static let sz = ImageAsset(name: "SZ")
  internal static let tc = ImageAsset(name: "TC")
  internal static let td = ImageAsset(name: "TD")
  internal static let tg = ImageAsset(name: "TG")
  internal static let th = ImageAsset(name: "TH")
  internal static let tj = ImageAsset(name: "TJ")
  internal static let tl = ImageAsset(name: "TL")
  internal static let tm = ImageAsset(name: "TM")
  internal static let tn = ImageAsset(name: "TN")
  internal static let to = ImageAsset(name: "TO")
  internal static let tr = ImageAsset(name: "TR")
  internal static let tt = ImageAsset(name: "TT")
  internal static let tv = ImageAsset(name: "TV")
  internal static let tz = ImageAsset(name: "TZ")
  internal static let ua = ImageAsset(name: "UA")
  internal static let ug = ImageAsset(name: "UG")
  internal static let us = ImageAsset(name: "US")
  internal static let uy = ImageAsset(name: "UY")
  internal static let uz = ImageAsset(name: "UZ")
  internal static let va = ImageAsset(name: "VA")
  internal static let vc = ImageAsset(name: "VC")
  internal static let ve = ImageAsset(name: "VE")
  internal static let vg = ImageAsset(name: "VG")
  internal static let vi = ImageAsset(name: "VI")
  internal static let vn = ImageAsset(name: "VN")
  internal static let vu = ImageAsset(name: "VU")
  internal static let wf = ImageAsset(name: "WF")
  internal static let ws = ImageAsset(name: "WS")
  internal static let xk = ImageAsset(name: "XK")
  internal static let ye = ImageAsset(name: "YE")
  internal static let yt = ImageAsset(name: "YT")
  internal static let za = ImageAsset(name: "ZA")
  internal static let zm = ImageAsset(name: "ZM")
  internal static let zw = ImageAsset(name: "ZW")
  internal static let email = ImageAsset(name: "email")
  internal static let unlockWallet = ImageAsset(name: "unlock-wallet")
  internal static let alert = ImageAsset(name: "alert")
  internal static let arrowDown = ImageAsset(name: "arrow-down")
  internal static let back = ImageAsset(name: "back")
  internal static let badge = ImageAsset(name: "badge")
  internal static let balance = ImageAsset(name: "balance")
  internal static let bank = ImageAsset(name: "bank")
  internal static let bullet = ImageAsset(name: "bullet")
  internal static let calendar = ImageAsset(name: "calendar")
  internal static let cancel = ImageAsset(name: "cancel")
  internal static let card = ImageAsset(name: "card")
  internal static let chat = ImageAsset(name: "chat")
  internal static let check = ImageAsset(name: "check")
  internal static let check2Circled = ImageAsset(name: "check2-circled")
  internal static let check2 = ImageAsset(name: "check2")
  internal static let checkboxSelectedCircle = ImageAsset(name: "checkbox-selected-circle")
  internal static let checkboxSelected = ImageAsset(name: "checkbox-selected")
  internal static let checkbox = ImageAsset(name: "checkbox")
  internal static let checked = ImageAsset(name: "checked")
  internal static let chevronDown = ImageAsset(name: "chevron-down")
  internal static let chevronLeft = ImageAsset(name: "chevron-left")
  internal static let chevronRight = ImageAsset(name: "chevron-right")
  internal static let chevronUp = ImageAsset(name: "chevron-up")
  internal static let close = ImageAsset(name: "close")
  internal static let coins = ImageAsset(name: "coins")
  internal static let copy = ImageAsset(name: "copy")
  internal static let distribute = ImageAsset(name: "distribute")
  internal static let driversLicense = ImageAsset(name: "drivers_license")
  internal static let echosystem = ImageAsset(name: "echosystem")
  internal static let edit = ImageAsset(name: "edit")
  internal static let empty = ImageAsset(name: "empty")
  internal static let exchange = ImageAsset(name: "exchange")
  internal static let fav = ImageAsset(name: "fav")
  internal static let filter = ImageAsset(name: "filter")
  internal static let forward = ImageAsset(name: "forward")
  internal static let help = ImageAsset(name: "help")
  internal static let history = ImageAsset(name: "history")
  internal static let home = ImageAsset(name: "home")
  internal static let idCard = ImageAsset(name: "id_card")
  internal static let info = ImageAsset(name: "info")
  internal static let loader = ImageAsset(name: "loader")
  internal static let lockClosed = ImageAsset(name: "lock_closed")
  internal static let lockOpen = ImageAsset(name: "lock_open")
  internal static let love = ImageAsset(name: "love")
  internal static let mail = ImageAsset(name: "mail")
  internal static let more = ImageAsset(name: "more")
  internal static let passport = ImageAsset(name: "passport")
  internal static let pending = ImageAsset(name: "pending")
  internal static let qr = ImageAsset(name: "qr")
  internal static let receive = ImageAsset(name: "receive")
  internal static let reorganize = ImageAsset(name: "reorganize")
  internal static let search = ImageAsset(name: "search")
  internal static let selected = ImageAsset(name: "selected")
  internal static let selectedGray = ImageAsset(name: "selected_gray")
  internal static let send = ImageAsset(name: "send")
  internal static let settings = ImageAsset(name: "settings")
  internal static let shield = ImageAsset(name: "shield")
  internal static let support = ImageAsset(name: "support")
  internal static let swap = ImageAsset(name: "swap")
  internal static let timelapse = ImageAsset(name: "timelapse")
  internal static let trash = ImageAsset(name: "trash")
  internal static let user = ImageAsset(name: "user")
  internal static let visibilityoff = ImageAsset(name: "visibilityoff")
  internal static let visibilityon = ImageAsset(name: "visibilityon")
  internal static let wallet = ImageAsset(name: "wallet")
  internal static let warning = ImageAsset(name: "warning")
  internal static let withdrawal = ImageAsset(name: "withdrawal")
  internal static let dragControl = ImageAsset(name: "DragControl")
  internal static let access = ImageAsset(name: "access")
  internal static let assets = ImageAsset(name: "assets")
  internal static let cards = ImageAsset(name: "cards")
  internal static let celebrate = ImageAsset(name: "celebrate")
  internal static let documents = ImageAsset(name: "documents")
  internal static let error = ImageAsset(name: "error")
  internal static let files = ImageAsset(name: "files")
  internal static let finance = ImageAsset(name: "finance")
  internal static let ilCard = ImageAsset(name: "il_card")
  internal static let ilMail = ImageAsset(name: "il_mail")
  internal static let ilSend = ImageAsset(name: "il_send")
  internal static let ilSetup = ImageAsset(name: "il_setup")
  internal static let ilVerificationsuccessfull = ImageAsset(name: "il_verificationsuccessfull")
  internal static let ilVerificationunsuccessfull = ImageAsset(name: "il_verificationunsuccessfull")
  internal static let profile = ImageAsset(name: "profile")
  internal static let recoveryPhrase1st = ImageAsset(name: "recovery_phrase_1st ")
  internal static let security = ImageAsset(name: "security")
  internal static let setup2 = ImageAsset(name: "setup-2")
  internal static let success = ImageAsset(name: "success")
  internal static let time = ImageAsset(name: "time")
  internal static let timeoutStatusIcon = ImageAsset(name: "timeoutStatusIcon")
  internal static let unlockWalletDisabled = ImageAsset(name: "unlock-wallet-disabled")
  internal static let verification = ImageAsset(name: "verification")
  internal static let world = ImageAsset(name: "world")
  internal static let logo = ImageAsset(name: "logo")
  internal static let logoIcon = ImageAsset(name: "logo_icon")
  internal static let logoIconWhite = ImageAsset(name: "logo_icon_white")
  internal static let logoVertical = ImageAsset(name: "logo_vertical")
  internal static let logoVerticalWhite = ImageAsset(name: "logo_vertical_white")
  internal static let logoWhite = ImageAsset(name: "logo_white")
  internal static let completeIcon = ImageAsset(name: "completeIcon")
  internal static let errorIcon = ImageAsset(name: "errorIcon")
  internal static let pendingIcon = ImageAsset(name: "pendingIcon")
  internal static let refundedIcon = ImageAsset(name: "refundedIcon")
  internal static let mastercard = ImageAsset(name: "MASTERCARD")
  internal static let visa = ImageAsset(name: "VISA")
  internal static let ensIcon = ImageAsset(name: "ensIcon")
  internal static let fioIcon = ImageAsset(name: "fioIcon")
  internal static let payidIcon = ImageAsset(name: "payidIcon")
  internal static let udomainIcon = ImageAsset(name: "udomainIcon")
  internal static let rightArrow = ImageAsset(name: "RightArrow")
  internal static let segWitLogo = ImageAsset(name: "SegWitLogo")
  internal static let share = ImageAsset(name: "Share")
  internal static let touchIDCutout = ImageAsset(name: "TouchIDCutout")
  internal static let touchIdLarge = ImageAsset(name: "TouchId-Large")
  internal static let touchId = ImageAsset(name: "TouchId")
  internal static let blockset = ImageAsset(name: "blockset")
  internal static let unlock = ImageAsset(name: "unlock")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
