import Foundation

struct BibleBookMetadata: Identifiable {
    let id: String  // abbreviation
    let latin: String
    let english: String
    let order: Int
    
    static var allBooks: [BibleBookMetadata] = {
        // Define the metadata as a static property
        let metadata = """
abbr,english
Gn,Genesis
Ex,Exodus
Lv,Leviticus
Nm,Numeri
Dt,Deuteronomium
Jos,Josue
Jdc,Judicum
Rt,Ruth
1Rg,Regum I
2Rg,Regum II
3Rg,Regum III
4Rg,Regum IV
1Par,Paralipomenon I
2Par,Paralipomenon II
Esr,Esdrae
Neh,Nehemiae
Tob,Tobiae
Jdt,Judith
Est,Esther
Job,Job
Ps,Psalmi
Pr,Proverbia
Ecl,Ecclesiastes
Ct,Canticum Canticorum
Sap,Sapientia
Sir,Ecclesiasticus
Is,Isaias
Jr,Jeremias
Lam,Lamentationes
Bar,Baruch
Ez,Ezechiel
Dn,Daniel
Os,Osee
Joel,Joel
Am,Amos
Abd,Abdias
Jon,Jonas
Mch,Michaea
Nah,Nahum
Hab,Habacuc
Soph,Sophonias
Agg,Aggaeus
Zach,Zacharias
Mal,Malachias
1Mcc,Machabaeorum I
2Mcc,Machabaeorum II
Mt,Matthaeus
Mc,Marcus
Lc,Lucas
Jo,Joannes
Act,Actus Apostolorum
Rom,ad Romanos
1Cor,ad Corinthios I
2Cor,ad Corinthios II
Gal,ad Galatas
Eph,ad Ephesios
Phlp,ad Philippenses
Col,ad Colossenses
1Thes,ad Thessalonicenses I
2Thes,ad Thessalonicenses II
1Tim,ad Timotheum I
2Tim,ad Timotheum II
Tit,ad Titum
Phlm,ad Philemonem
Hbr,ad Hebraeos
Jac,Jacobi
1Ptr,Petri I
2Ptr,Petri II
1Jo,Joannis I
2Jo,Joannis II
3Jo,Joannis III
Jud,Judae
Apc,Apocalypsis
"""
        
        return metadata.components(separatedBy: .newlines)
            .dropFirst() // Skip header
            .enumerated()
            .compactMap { index, line -> BibleBookMetadata? in
                let components = line.components(separatedBy: ",")
                guard components.count == 2, !components[0].isEmpty else { return nil }
                return BibleBookMetadata(
                    id: components[0],
                    latin: components[1],
                    english: components[1],
                    order: index
                )
            }
    }()
    
    static func getOrder(for bookName: String) -> Int {
        if let metadata = allBooks.first(where: { $0.latin == bookName }) {
            return metadata.order
        }
        // Return a large number for unknown books to put them at the end
        return 1000
    }
} 