//
//  TeamFactory.swift
//  Sports
//
//  Created by Wesley St. John on 12/22/21.
//

import UIKit

class TeamFactory {

    private static let teamConfigs: [TeamConfig] = [
        TeamConfig(teamName: "Manchester City",
                   teamLongName: "Manchester City F.C.",
                   teamShortName: "MCT",
                   nickName: "Citizens",
                   imageName: "team_icon_manchester_city",
                   primaryColor: UIColor.rgb(r: 100, g: 173, b: 221),
                   secondaryColor: UIColor.rgb(r: 2, g: 33, b: 63),
                   prestige: "⭐️⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Liverpool",
                   teamLongName: "Liverpool F.C.",
                   teamShortName: "LIV",
                   nickName: "Reds",
                   imageName: "team_icon_liverpool",
                   primaryColor: UIColor.rgb(r: 219, g: 10, b: 22),
                   secondaryColor: UIColor.rgb(r: 21, g: 150, b: 127),
                   prestige: "⭐️⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Chelsea",
                   teamLongName: "Chelsea F.C.",
                   teamShortName: "CHE",
                   nickName: "Blues",
                   imageName: "team_icon_chelsea",
                   primaryColor: UIColor.rgb(r: 8, g: 71, b: 147),
                   secondaryColor: UIColor.rgb(r: 240, g: 228, b: 53),
                   prestige: "⭐️⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Arsenal",
                   teamLongName: "Arsenal F.C.",
                   teamShortName: "ARS",
                   nickName: "Gunners",
                   imageName: "team_icon_arsenal",
                   primaryColor: UIColor.rgb(r: 237, g: 11, b: 25),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Manchester United",
                   teamLongName: "Manchester United F.C.",
                   teamShortName: "MUN",
                   nickName: "Red Devils",
                   imageName: "team_icon_manchester_united",
                   primaryColor: UIColor.rgb(r: 252, g: 13, b: 27),
                   secondaryColor: UIColor.rgb(r: 254, g: 228, b: 51),
                   prestige: "⭐️⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "West Ham",
                   teamLongName: "West Ham United F.C.",
                   teamShortName: "WHM",
                   nickName: "Irons",
                   imageName: "team_icon_west_ham",
                   primaryColor: UIColor.rgb(r: 151, g: 6, b: 20),
                   secondaryColor: UIColor.rgb(r: 157, g: 208, b: 242),
                   prestige: "⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Tottenham",
                   teamLongName: "Tottenham Hotspur F.C.",
                   teamShortName: "TOT",
                   nickName: "Lilywhites",
                   imageName: "team_icon_tottenham",
                   primaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   secondaryColor: UIColor.rgb(r: 1, g: 24, b: 76),
                   prestige: "⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Wolverhampton",
                   teamLongName: "Wolverhampton Wanderers F.C.",
                   teamShortName: "WLV",
                   nickName: "Wolves",
                   imageName: "team_icon_wolverhampton",
                   primaryColor: UIColor.rgb(r: 253, g: 153, b: 39),
                   secondaryColor: UIColor.rgb(r: 0, g: 0, b: 0),
                   prestige: "⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Leicester City",
                   teamLongName: "Leicester City F.C.",
                   teamShortName: "LCT",
                   nickName: "Foxes",
                   imageName: "team_icon_leicester_city",
                   primaryColor: UIColor.rgb(r: 11, g: 36, b: 251),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Crystal Palace",
                   teamLongName: "Crystal Palace F.C.",
                   teamShortName: "CPL",
                   nickName: "Eagles",
                   imageName: "team_icon_crystal_palace",
                   primaryColor: UIColor.rgb(r: 252, g: 13, b: 27),
                   secondaryColor: UIColor.rgb(r: 14, g: 77, b: 251),
                   prestige: "⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Brighton",
                   teamLongName: "Brighton & Hove Albion F.C.",
                   teamShortName: "BRT",
                   nickName: "Seagulls",
                   imageName: "team_icon_brighton",
                   primaryColor: UIColor.rgb(r: 10, g: 33, b: 238),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Aston Villa",
                   teamLongName: "Aston Villa F.C.",
                   teamShortName: "AVL",
                   nickName: "Lions",
                   imageName: "team_icon_aston_villa",
                   primaryColor: UIColor.rgb(r: 166, g: 204, b: 253),
                   secondaryColor: UIColor.rgb(r: 132, g: 4, b: 30),
                   prestige: "⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Southampton",
                   teamLongName: "Southampton F.C.",
                   teamShortName: "STH",
                   nickName: "Saints",
                   imageName: "team_icon_southampton",
                   primaryColor: UIColor.rgb(r: 252, g: 13, b: 27),
                   secondaryColor: UIColor.rgb(r: 224, g: 224, b: 224),
                   prestige: "⭐️⭐️⭐️"
                  ),
        TeamConfig(teamName: "Brentford",
                   teamLongName: "Brentford F.C.",
                   teamShortName: "BRF",
                   nickName: "Bees",
                   imageName: "team_icon_brentford",
                   primaryColor: UIColor.rgb(r: 252, g: 13, b: 27),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️⭐️"
                  ),
        TeamConfig(teamName: "Everton",
                   teamLongName: "Everton F.C.",
                   teamShortName: "EVT",
                   nickName: "Blues",
                   imageName: "team_icon_everton",
                   primaryColor: UIColor.rgb(r: 8, g: 30, b: 219),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️⭐️"
                  ),
        TeamConfig(teamName: "Leeds United",
                   teamLongName: "Leeds United F.C.",
                   teamShortName: "LEE",
                   nickName: "Whites",
                   imageName: "team_icon_leeds_united",
                   primaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   secondaryColor: UIColor.rgb(r: 20, g: 36, b: 86),
                   prestige: "⭐️⭐️"
                  ),
        TeamConfig(teamName: "Watford",
                   teamLongName: "Watford F.C.",
                   teamShortName: "WTF",
                   nickName: "Hornets",
                   imageName: "team_icon_watford",
                   primaryColor: UIColor.rgb(r: 253, g: 226, b: 58),
                   secondaryColor: UIColor.rgb(r: 0, g: 0, b: 0),
                   prestige: "⭐️⭐️"
                  ),
        TeamConfig(teamName: "Burnley",
                   teamLongName: "Burnley F.C.",
                   teamShortName: "BRN",
                   nickName: "Clarets",
                   imageName: "team_icon_burnley",
                   primaryColor: UIColor.rgb(r: 128, g: 3, b: 29),
                   secondaryColor: UIColor.rgb(r: 132, g: 193, b: 253),
                   prestige: "⭐️"
                  ),
        TeamConfig(teamName: "Newcastle United",
                   teamLongName: "Newcastle United F.C.",
                   teamShortName: "NCS",
                   nickName: "Magpies",
                   imageName: "team_icon_newcastle",
                   primaryColor: UIColor.rgb(r: 0, g: 0, b: 0),
                   secondaryColor: UIColor.rgb(r: 255, g: 255, b: 255),
                   prestige: "⭐️"
                  ),
        TeamConfig(teamName: "Norwich City",
                   teamLongName: "Norwich City F.C.",
                   teamShortName: "NWC",
                   nickName: "Canaries",
                   imageName: "team_icon_norwich_city",
                   primaryColor: UIColor.rgb(r: 255, g: 240, b: 53),
                   secondaryColor: UIColor.rgb(r: 21, g: 152, b: 70),
                   prestige: "⭐️"
                  )
        ]

    static func makeTeam(index: Int) -> Team {
        guard index < teamConfigs.count else {
            return Team(id: UUID().uuidString,
                        name: "Team \(index + 1)",
                        longName: "Team \(index + 1)",
                        shortName: "TM\(index + 1)",
                        nickName: "Team \(index + 1)",
                        iconName: nil,
                        primaryColor: .white,
                        secondaryColor: .black,
                        prestige: "⭐️",
                        players: [])
        }

        let config = teamConfigs[index]
        return Team(id: UUID().uuidString,
                    name: config.teamName,
                    longName: config.teamLongName,
                    shortName: config.teamShortName,
                    nickName: config.nickName,
                    iconName: config.imageName,
                    primaryColor: config.primaryColor,
                    secondaryColor: config.secondaryColor,
                    prestige: config.prestige,
                    players: [])
    }
}

private struct TeamConfig {
    let teamName: String
    let teamLongName: String
    let teamShortName: String
    let nickName: String
    let imageName: String
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let prestige: String
}

extension UIColor {
    static let keeperHomeColor = UIColor.rgb(r: 230, g: 34, b: 214)
    static let keeperAwayColor = UIColor.rgb(r: 141, g: 35, b: 238)

    static func rgb(r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0,
                       green: CGFloat(g)/255.0,
                       blue: CGFloat(b)/255.0,
                       alpha: 1)
    }
}
