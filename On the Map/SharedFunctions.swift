//
//  SharedFunctions.swift
//  On the Map
//
//  Created by nekki t on 2015/12/25.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit

class SharedFunctions {
    
    static let MaxColorValue: CGFloat = 255.0

    class func showAlert(title: String?, message: String?, targetViewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "Dissmiss", style: .Default, handler: nil)
        alert.addAction(actionOK)
        targetViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Configure button for the posting view
    class func setPostingButton(button: BorderedButton){
        
        // MARK: - Constants
        let MaxColorValue: CGFloat = 255.0
        
        // Configure login button
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        
        button.highlightedBackingColor = UIColor(red: 39/MaxColorValue, green: 252/MaxColorValue, blue: 233/MaxColorValue, alpha:1.0)
        button.backingColor = UIColor.whiteColor()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitleColor(UIColor(red: 65/MaxColorValue, green: 117/MaxColorValue, blue:165/MaxColorValue, alpha:1.0), forState: .Normal)
    }

    // Shared Dark Orange Color
    class func getDarkOrangeColor () -> UIColor{
        return UIColor(red: 238/MaxColorValue, green:61/MaxColorValue, blue:6/MaxColorValue, alpha: 1.0)
    }
    
    // Shared Light Orange Color
    class func getLightOrangeColor() -> UIColor {
        return UIColor(red: 248/MaxColorValue, green: 186/MaxColorValue, blue: 129/MaxColorValue, alpha:1.0)
    }
    
    class func getTopMostViewController()->UIViewController{
        var tc = UIApplication.sharedApplication().keyWindow?.rootViewController;
        while ((tc!.presentedViewController) != nil) {
            tc = tc!.presentedViewController;
        }
        return tc!;
    }
    
    class func getCountryFlagImagePath(countryCode: String!) -> String? {
        var countryCodes = [String: String]()
        countryCodes["AF"] = "afghanistan"
        countryCodes["AL"] = "albania"
        countryCodes["AM"] = "armenia"
        countryCodes["AN"] = "netherlands antilles"
        countryCodes["AO"] = "angola"
        countryCodes["AR"] = "argentine"
        countryCodes["AT"] = "austria"
        countryCodes["AU"] = "australia"
        countryCodes["AW"] = "aruba"
        countryCodes["AZ"] = "azerbaijan"
        countryCodes["BA"] = "bosnia-herzegovina"
        countryCodes["BB"] = "barbados"
        countryCodes["BD"] = "bangladesh"
        countryCodes["BE"] = "belgium"
        countryCodes["BF"] = "burkina-faso"
        countryCodes["BG"] = "bulgaria"
        countryCodes["BH"] = "bahrain"
        countryCodes["BJ"] = "benin"
        countryCodes["BN"] = "brunei-darussalam"
        countryCodes["BO"] = "bolivia"
        countryCodes["BR"] = "brazil"
        countryCodes["BS"] = "bahamas"
        countryCodes["BW"] = "botswana"
        countryCodes["BY"] = "belarus"
        countryCodes["BZ"] = "belize"
        countryCodes["CA"] = "canada"
        countryCodes["CF"] = "central-african"
        countryCodes["CG"] = "congo-kyowa"
        countryCodes["CH"] = "switzerland"
        countryCodes["CI"] = "cote-divoire"
        countryCodes["CK"] = "cook"
        countryCodes["CL"] = "chile"
        countryCodes["CM"] = "cameroon"
        countryCodes["CN"] = "china"
        countryCodes["CO"] = "colombia"
        countryCodes["CR"] = "costarica"
        countryCodes["CU"] = "cuba"
        countryCodes["CV"] = "capeverde"
        countryCodes["CY"] = "cyprus"
        countryCodes["CZ"] = "czech"
        countryCodes["DE"] = "germany"
        countryCodes["DJ"] = "djibouti"
        countryCodes["DK"] = "denmark"
        countryCodes["DM"] = "dominica-koku"
        countryCodes["DO"] = "dominican-kyowa"
        countryCodes["DZ"] = "algeria"
        countryCodes["EC"] = "ecuador"
        countryCodes["EE"] = "estonia"
        countryCodes["EG"] = "egypt"
        countryCodes["EH"] = "west-sahara"
        countryCodes["ER"] = "eritrea"
        countryCodes["ES"] = "spain"
        countryCodes["ET"] = "ethiopia"
        countryCodes["EU"] = "eu"
        countryCodes["FI"] = "finland"
        countryCodes["FJ"] = "fiji"
        countryCodes["FK"] = "falkland islands (malvinas)"
        countryCodes["FM"] = "micronesia, federated states of"
        countryCodes["FO"] = "faroes"
        countryCodes["FR"] = "france"
        countryCodes["GA"] = "gabon"
        countryCodes["GB"] = "england"
        countryCodes["GD"] = "grenada"
        countryCodes["GE"] = "georgia"
        countryCodes["GF"] = "guyana"
        countryCodes["GH"] = "ghana"
        countryCodes["GL"] = "greenland"
        countryCodes["GM"] = "gambia"
        countryCodes["GN"] = "guinea"
        countryCodes["GR"] = "greece"
        countryCodes["GT"] = "guatemala"
        countryCodes["GY"] = "guyana"
        countryCodes["HK"] = "hongkong"
        countryCodes["HN"] = "honduras"
        countryCodes["HR"] = "croatia"
        countryCodes["HT"] = "haiti"
        countryCodes["HU"] = "hungary"
        countryCodes["ID"] = "indonesia"
        countryCodes["IE"] = "ireland"
        countryCodes["IL"] = "israel"
        countryCodes["IN"] = "india"
        countryCodes["IQ"] = "iraq"
        countryCodes["IR"] = "iran"
        countryCodes["IS"] = "iceland"
        countryCodes["IT"] = "italy"
        countryCodes["JM"] = "jamaica"
        countryCodes["JO"] = "jordan"
        countryCodes["JP"] = "japan"
        countryCodes["KE"] = "kenya"
        countryCodes["KG"] = "kyrgyzs"
        countryCodes["KH"] = "cambodia"
        countryCodes["KI"] = "kiribati"
        countryCodes["KM"] = "comoros"
        countryCodes["KP"] = "north_korea"
        countryCodes["KR"] = "korea"
        countryCodes["KW"] = "kuwait"
        countryCodes["KY"] = "cayman islands"
        countryCodes["KZ"] = "kazakhstan"
        countryCodes["LA"] = "laos"
        countryCodes["LB"] = "lebanon"
        countryCodes["LC"] = "saint-lucia"
        countryCodes["LI"] = "liechtenstein"
        countryCodes["LK"] = "srilanka"
        countryCodes["LR"] = "liberia"
        countryCodes["LS"] = "lesotho"
        countryCodes["LT"] = "lithuania"
        countryCodes["LU"] = "luxembourg"
        countryCodes["LV"] = "latvia"
        countryCodes["LY"] = "libya"
        countryCodes["MA"] = "morocco"
        countryCodes["MC"] = "monaco"
        countryCodes["MD"] = "moldova"
        countryCodes["ME"] = "montenegro"
        countryCodes["MG"] = "madagascar"
        countryCodes["MH"] = "marshall"
        countryCodes["MK"] = "macedonia"
        countryCodes["ML"] = "mali"
        countryCodes["MM"] = "myanmar"
        countryCodes["MN"] = "mongolia"
        countryCodes["MO"] = "macau"
        countryCodes["MP"] = "north-mariana"
        countryCodes["MR"] = "mauritania"
        countryCodes["MT"] = "malta"
        countryCodes["MU"] = "mauritius"
        countryCodes["MV"] = "maldives"
        countryCodes["MW"] = "malawi"
        countryCodes["MX"] = "mexico"
        countryCodes["MY"] = "malaysia"
        countryCodes["MZ"] = "mozambique"
        countryCodes["NA"] = "namibia"
        countryCodes["NC"] = "new-caledonie"
        countryCodes["NE"] = "niger"
        countryCodes["NG"] = "nigeria"
        countryCodes["NI"] = "nicaragua"
        countryCodes["NL"] = "netherlands"
        countryCodes["NO"] = "norway"
        countryCodes["NP"] = "nepal"
        countryCodes["NR"] = "nauru"
        countryCodes["NU"] = "niue"
        countryCodes["NZ"] = "newzealand"
        countryCodes["OM"] = "oman"
        countryCodes["PA"] = "panama"
        countryCodes["PE"] = "peru"
        countryCodes["PG"] = "papua-newguinea"
        countryCodes["PH"] = "philippines"
        countryCodes["PK"] = "pakistan"
        countryCodes["PL"] = "poland"
        countryCodes["PR"] = "puerto-rico"
        countryCodes["PS"] = "palestina"
        countryCodes["PT"] = "portugal"
        countryCodes["PW"] = "palau"
        countryCodes["PY"] = "paraguay"
        countryCodes["QA"] = "qatar"
        countryCodes["RO"] = "romania"
        countryCodes["RS"] = "serbia"
        countryCodes["RU"] = "russian"
        countryCodes["RW"] = "rwanda"
        countryCodes["SA"] = "saudi-arabia"
        countryCodes["SC"] = "seychelles"
        countryCodes["SD"] = "sudan"
        countryCodes["SE"] = "sweden"
        countryCodes["SG"] = "singapore"
        countryCodes["SI"] = "slovenia"
        countryCodes["SK"] = "slovak"
        countryCodes["SM"] = "sanmarino"
        countryCodes["SN"] = "senegal"
        countryCodes["SO"] = "somalia"
        countryCodes["SR"] = "suriname"
        countryCodes["SV"] = "elsalvador"
        countryCodes["SY"] = "syrian"
        countryCodes["SZ"] = "swaziland"
        countryCodes["TD"] = "chad"
        countryCodes["TG"] = "togo"
        countryCodes["TH"] = "thailand"
        countryCodes["TJ"] = "tajikistan"
        countryCodes["TM"] = "turkmenistan"
        countryCodes["TN"] = "tunisia"
        countryCodes["TO"] = "tonga"
        countryCodes["TR"] = "turkey"
        countryCodes["TT"] = "trinidad-tobago"
        countryCodes["TV"] = "tuvalu"
        countryCodes["TW"] = "taiwan"
        countryCodes["TZ"] = "tanzania"
        countryCodes["UA"] = "ukraine"
        countryCodes["UG"] = "uganda"
        countryCodes["UK"] = "england"
        countryCodes["US"] = "america"
        countryCodes["UY"] = "uruguay"
        countryCodes["UZ"] = "uzbekistan"
        countryCodes["VA"] = "vatican"
        countryCodes["VE"] = "venezuela"
        countryCodes["VG"] = "england"
        countryCodes["VI"] = "america"
        countryCodes["VN"] = "vietnam"
        countryCodes["VU"] = "vanuatu"
        countryCodes["WS"] = "samoa"
        countryCodes["YE"] = "yemen"
        countryCodes["YU"] = "yugoslavia"
        countryCodes["ZA"] = "south_africa"
        countryCodes["ZM"] = "zambia"
        countryCodes["ZW"] = "zimbabwe"

        
        if countryCodes.keys.contains(countryCode.uppercaseString) {
            return countryCodes[countryCode.uppercaseString]
            
        } else {
            return nil
        }
    }

}
