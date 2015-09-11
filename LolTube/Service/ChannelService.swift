import Foundation

class ChannelService: NSObject {    
    let appVersionKey = "appVersion"
    let channelIdsKey = "channleIds" 
    let sharedUserDefaultsSuitName = "kSharedUserDefaultsSuitName"
    let currentAppVersion = "2.0.0"
    
    private let cloudStore = NSUbiquitousKeyValueStore.defaultStore()
    
    private var userDefaults:NSUserDefaults{
        return NSUserDefaults(suiteName: sharedUserDefaultsSuitName) ?? NSUserDefaults.standardUserDefaults()
    }
    private var appVersion:String?{
        let userDefaults = NSUserDefaults(suiteName: sharedUserDefaultsSuitName) ?? NSUserDefaults.standardUserDefaults()
        return userDefaults.stringForKey(appVersionKey)
    }
    
    
    private enum DefaultChannel:String {
        // english channels
        case LeagueofLegends = "UC2t5bjwHdUX4vM2g8TRDq5g"
        case LoLEsports = "UCvqRdlKsE5Q8mf8YXbdIJLw"
        case Protatomonster = "UClh5azhOaKzdlThQFgoq"
        case OPLOLReplay = "UC0RalGf69iYVBFteHInyJJg"
        case Redmercy = "UCUf53DHwoQw4SvETXZQ2Tmg"
        case Jumpinthepack = "UCPOm2V7Ccdlkm2J1TqNptEw"
        case dodgedlol = "UCrZT1akje889ZcVXDf9QkGg"
        case ProReplays = "UCGgbmTgF-sUJGd5B5N6VSFw"
        case Nightblue3 = "UCN078UFNwPgwWlU_V5WCTNw"
        case MachinimaRealm = "UCVEbcFWM43PS-d5vaSKUMng"
        case LoLVoyboy = "UCBJLvzKYBCQJc1buauA3msw"
        case EpicSkillshot = "UCdOWyp25T0HDtjpnV2LpIyw"
        case PantsareDragon = "UChBb5BEX36y-DXK7uISYbzg"
        case Phylol = "UCARZJejxRnmQ0m_tU7MgRiA"
        case LoLeaks = "UCtHosYGpdBx-X7uEkhJX7yg"
        case LeagueOfGosu = "UCudNGAQXzpE1sMfoqPs67mQ"
        case LOLPROReplays = "UCYX9IB_lU43EenSWKDlheUg"
        case Respawnd = "UCkEUlvLiYxg5xzByy0yilrQ"
        case Sp4zie = "UCmtQGojT9O2LVzVIVKDGEjw"
        case MiDOrAFK = "UCnoSiiatisjE3RbM7DgdFmA"
        case TheCarry = "UCTkeYBsxfJcsqi9kMbqLsfA"
        
        // chinese channels
        
        case LeagueofLegendsTW = "UCekadoaN7x7g7FlmKg13jWg"
        case FåntäsyZ = "UCDgtlI_erc41UoqaeD816Kg"
        case 英雄聯盟最新資訊 = "UC_iOMGX-tdJKvjPEvy8z7Fw"
        case 云之彼岸LOL = "UCk2_iV0Q1EPbOiJ6aOOLbZw"
        case 最強聯盟BestLeague = "UCtMM6QD3n-jCjUfvflarboA"
        case 最強聯盟爆笑集錦x直播頻 = "UCNooNOGnABoxyDwHuQAH92w"
        case R大 = "UCcUrfKffo1wjIZ_GMKgPEqQ"
        case Solagas = "UCmqOPqjtFi-QppW3wDhPWEg"
        case 遊戲大聯盟 = "LOLGAMEPLAY999"
        case MRNLF = "UCzVVSZsI9NH3yfYRJnBYdZw"
        case 至尊英雄聯盟 = "UCt-vmycaqV5Y9B63z8uDyBA"
        case LOL小智解說 = "UCE-M1BWmaXwAWPJ_iRzgzFg"
        case 英雄聯盟日常 = "UCjhL_2c-XYs8xtrKTflgo5Q"
        case SKTT1FakerSoloQueue = "UCXJ2HbqZ7b-L6G9rWyPFfow"
        case GarenaTaiwan = "UCCqnLewexMM7LwGzqpMpPrA"
        case SivHD中譯版 = "UCgO0J4fCNTyU-PibDiNEFjQ"
        case ahqESportsClub = "UChXDO6h-vhSyoQQMz9vQ6YQ"
        case GG3B0 = "UClN448pkRACE6X0NNGzGQtg"
        case Dinter = "UC0SkNQXPJ60hKEFubOz0fDA"
        case 烏啦啦 = "UCjvjMvoMY1GgXc04VntTZhg"
        case HongKongEsportsLtd = "UCMwKmIVf-ZT7eQTkof6IzPw"
        
        // korean channels
        case RangmalTV = "UCc_7XbnN1bTFMhquCKt3ngA"
        
        static func englishChannels() -> [DefaultChannel]{
            return [
                .LeagueofLegends,
                .LoLEsports,
                .Protatomonster,
                .OPLOLReplay,
                .Redmercy,
                .Jumpinthepack,
                .dodgedlol,
                .ProReplays,
                .Nightblue3,
                .MachinimaRealm,
                .LoLVoyboy,
                .EpicSkillshot,
                .PantsareDragon,
                .Phylol,
                .LoLeaks,
                .LeagueOfGosu,
                .LOLPROReplays,
                .Respawnd,
                .Sp4zie,
                .MiDOrAFK,
                .TheCarry
            ]
        }
        
        static func chineseChannels() -> [DefaultChannel]{
            return [
                .LeagueofLegendsTW,
                .LoLEsports,
                .FåntäsyZ,
                .英雄聯盟最新資訊,
                .云之彼岸LOL,
                .最強聯盟BestLeague,
                .最強聯盟爆笑集錦x直播頻,
                .R大,
                .Solagas,
                .遊戲大聯盟,
                .MRNLF,
                .至尊英雄聯盟,
                .LOL小智解說,
                .英雄聯盟日常,
                .SKTT1FakerSoloQueue,
                .GarenaTaiwan,
                .SivHD中譯版,
                .ahqESportsClub,
                .GG3B0,
                .Dinter,
                .烏啦啦,
                .HongKongEsportsLtd,
                .OPLOLReplay,
                .EpicSkillshot
            ]
        }
        
        static func koreanChannels() -> [DefaultChannel]{
            return [.RangmalTV]
        }
    }
    
    
    func channelIds() -> [String] {                
        guard let channelIds = userDefaults.arrayForKey(channelIdsKey) as? [String] else {
            guard appVersion == currentAppVersion else {                
                saveDefaultChannelIds()
                saveAppVersion()
                return userDefaults.arrayForKey(channelIdsKey) as! [String]
            }
            
            let cloudChannelIds = cloudStore.arrayForKey(channelIdsKey) as? [String]
            if let cloudChannelIds = cloudChannelIds {
                saveChannelIds(cloudChannelIds)
            } else {
                saveDefaultChannelIds()
                saveAppVersion()
            }
            
            return userDefaults.arrayForKey(channelIdsKey) as! [String]
        }
            
        return channelIds
    }
        
    private func saveDefaultChannelIds(){
        let channelIds:[DefaultChannel] 
        if let language =  NSBundle.mainBundle().preferredLocalizations.first {                    
            if language.hasPrefix("zh-Hant") {
                channelIds = DefaultChannel.chineseChannels()  
            } else {
                channelIds = DefaultChannel.englishChannels()  
            }
        } else {
            channelIds = DefaultChannel.englishChannels() 
        }
        
        save(key: channelIdsKey, value: channelIds.map{$0.rawValue})
    }
    
    
    private func saveAppVersion(){
        userDefaults.setObject("2.0.0", forKey: appVersionKey)
        userDefaults.synchronize()
    }
    
    func saveChannelId(channelId:String) {
        var channelIds = (userDefaults.arrayForKey(channelIdsKey) as? [String]) ?? []
        channelIds.append(channelId)
        
        save(key: channelIdsKey, value: channelIds)
    }
    
    func deleteChannelId(channelId:String){
        var channelIds = (userDefaults.arrayForKey(channelIdsKey) as? [String]) ?? []
        guard let index = channelIds.indexOf(channelId) else {
            return
        }
        channelIds.removeAtIndex(index)
        save(key: channelIdsKey, value: channelIds)
    }
    
    func saveChannelIds(channelIds:[String]){
        var savedChannelIds = (userDefaults.arrayForKey(channelIdsKey) as? [String]) ?? []
        savedChannelIds = savedChannelIds + channelIds  
        save(key: channelIdsKey, value: savedChannelIds)
    }
    
    private func save(key key:String,value:[String]){
        userDefaults.setObject(value, forKey: channelIdsKey)
        userDefaults.synchronize()
        
        cloudStore.setObject(value, forKey: channelIdsKey)
        cloudStore.synchronize()
    }

}