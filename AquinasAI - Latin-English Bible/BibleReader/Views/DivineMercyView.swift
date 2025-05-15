import SwiftUI

struct DivineMercyView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: PrayerLanguage = .bilingual
    @State private var scrollToId: String?
    
    // Add parameter for initial prayer ID
    let initialPrayerId: String?
    
    init(initialPrayerId: String? = nil) {
        self.initialPrayerId = initialPrayerId
        self._scrollToId = State(initialValue: initialPrayerId)
    }
    
    private var template: DivineMercyTemplate? {
        prayerStore.divineMercyPrayers?.divine_mercy_chaplet.template
    }
    
    private var commonPrayers: [String: DivineMercyPrayer]? {
        prayerStore.divineMercyPrayers?.divine_mercy_chaplet.common_prayers
    }
    
    var body: some View {
        VStack(spacing: 16) {
            LanguageSelectionView(selectedLanguage: $selectedLanguage)
            
            if let template = template, let commonPrayers = commonPrayers {
                DivineMercyContentView(
                    template: template,
                    commonPrayers: commonPrayers,
                    selectedLanguage: selectedLanguage,
                    scrollToId: scrollToId
                )
            } else {
                LoadingErrorView(isLoading: prayerStore.divineMercyPrayers == nil)
            }
        }
        .navigationTitle("Divine Mercy Chaplet")
    }
}

// MARK: - Language Selection View
private struct LanguageSelectionView: View {
    @Binding var selectedLanguage: PrayerLanguage
    
    var body: some View {
        Picker("Language", selection: $selectedLanguage) {
            ForEach(PrayerLanguage.allCases, id: \.self) { language in
                Text(language.rawValue.capitalized).tag(language)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

// MARK: - Divine Mercy Content View
private struct DivineMercyContentView: View {
    let template: DivineMercyTemplate
    let commonPrayers: [String: DivineMercyPrayer]
    let selectedLanguage: PrayerLanguage
    let scrollToId: String?
    
    @State private var viewHasAppeared = false
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    IntroductionView()
                    
                    // 1. Make the Sign of the Cross
                    SectionHeaderView(title: "1. Make the Sign of the Cross")
                    if let prayer = commonPrayers["sign_of_the_cross"] {
                        PrayerCardView(
                            prayer: prayer.asPrayer,
                            selectedLanguage: selectedLanguage,
                            shouldHighlight: scrollToId == prayer.asPrayer.id
                        )
                        .id(prayer.asPrayer.id)
                        .padding(.horizontal)
                    }
                    
                    // 2. Optional Opening Prayers
                    SectionHeaderView(title: "2. Optional Opening Prayers")
                    OptionaOpeningPrayersView(selectedLanguage: selectedLanguage)
                    
                    // 3, 4, 5. Our Father, Hail Mary, Apostles' Creed
                    OpeningPrayersView(
                        commonPrayers: commonPrayers,
                        selectedLanguage: selectedLanguage,
                        scrollToId: scrollToId
                    )
                    
                    // 6, 7, 8. The Chaplet Decades
                    DecadesView(
                        template: template,
                        commonPrayers: commonPrayers,
                        selectedLanguage: selectedLanguage,
                        scrollToId: scrollToId
                    )
                    
                    // 9. Holy God (3 times)
                    SectionHeaderView(title: "9. Holy God (Repeat three times)")
                    if let prayer = commonPrayers["holy_god"] {
                        RepeatedPrayerView(
                            prayer: prayer.asPrayer,
                            count: 3,
                            intentions: nil,
                            selectedLanguage: selectedLanguage,
                            shouldHighlight: scrollToId == prayer.asPrayer.id
                        )
                        .id(prayer.asPrayer.id)
                        .padding(.horizontal)
                    }
                    
                    // 10. Optional Closing Prayers
                    SectionHeaderView(title: "10. Optional Closing Prayers")
                    if let prayer = commonPrayers["closing_prayer"] {
                        PrayerCardView(
                            prayer: prayer.asPrayer,
                            selectedLanguage: selectedLanguage,
                            shouldHighlight: scrollToId == prayer.asPrayer.id
                        )
                        .id(prayer.asPrayer.id)
                        .padding(.horizontal)
                    }
                    
                    OptionalClosingPrayersView(selectedLanguage: selectedLanguage)
                }
                .padding(.vertical)
                .id("divine-mercy-content")
                .onAppear {
                    if !viewHasAppeared {
                        viewHasAppeared = true
                        
                        // Attempt to find and scroll to the prayer if an ID is provided
                        if let prayerId = scrollToId {
                            // Give time for the view to fully render
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                scrollToPrayer(id: prayerId, proxy: scrollProxy)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func scrollToPrayer(id: String, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
        }
    }
}

private struct IntroductionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to Recite the Chaplet")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.deepPurple)
            
            Text("The Chaplet of Divine Mercy is recited using ordinary Rosary beads of five decades. The Chaplet is preceded by two opening prayers from the Diary of Saint Maria Faustina Kowalska and followed by a closing prayer.")
                .font(.body)
                .padding(.bottom, 8)
        }
        .padding(.horizontal)
    }
}

private struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.deepPurple)
            .padding(.bottom, 4)
            .padding(.horizontal)
    }
}

private struct OptionaOpeningPrayersView: View {
    let selectedLanguage: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("St. Faustina's Prayer for Sinners")
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 2)
            
            if selectedLanguage == .latinOnly || selectedLanguage == .bilingual {
                Text("O Iesu, aeterna Veritas, Vita nostra, imploro et deprecor misericordiam Tuam pro peccatoribus.")
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if selectedLanguage == .englishOnly || selectedLanguage == .bilingual {
                Text("O Jesus, eternal Truth, our Life, I call upon You and I beg Your mercy for poor sinners. O sweetest Heart of my Lord, full of pity and unfathomable mercy, I plead with You for poor sinners. O Most Sacred Heart, Fount of Mercy from which gush forth rays of inconceivable graces upon the entire human race, I beg of You light for poor sinners. O Jesus, be mindful of Your own bitter Passion and do not permit the loss of souls redeemed at so dear a price of Your most precious Blood. O Jesus, when I consider the great price of Your Blood, I rejoice at its immensity, for one drop alone would have been enough for the salvation of all sinners. Although sin is an abyss of wickedness and ingratitude, the price paid for us can never be equalled. Therefore, let every soul trust in the Passion of the Lord, and place its hope in His mercy. God will not deny His mercy to anyone. Heaven and earth may change, but God's mercy will never be exhausted. Oh, what immense joy burns in my heart when I contemplate Your incomprehensible goodness, O Jesus! I desire to bring all sinners to Your feet that they may glorify Your mercy throughout endless ages.")
                    .font(.body)
                    .foregroundColor(selectedLanguage == .bilingual ? 
                                    (colorScheme == .dark ? .gray : .secondary) : 
                                    (colorScheme == .dark ? .white : .primary))
                    .italic(selectedLanguage == .bilingual)
                    .padding(.top, selectedLanguage == .bilingual ? 2 : 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

private struct OpeningPrayersView: View {
    let commonPrayers: [String: DivineMercyPrayer]
    let selectedLanguage: PrayerLanguage
    let scrollToId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 3. Our Father
            SectionHeaderView(title: "3. Our Father")
            if let prayer = commonPrayers["our_father"] {
                PrayerCardView(
                    prayer: prayer.asPrayer,
                    selectedLanguage: selectedLanguage,
                    shouldHighlight: scrollToId == prayer.asPrayer.id
                )
                .id(prayer.asPrayer.id)
                .padding(.horizontal)
            }
            
            // 4. Hail Mary
            SectionHeaderView(title: "4. Hail Mary")
            if let prayer = commonPrayers["hail_mary"] {
                PrayerCardView(
                    prayer: prayer.asPrayer,
                    selectedLanguage: selectedLanguage,
                    shouldHighlight: scrollToId == prayer.asPrayer.id
                )
                .id(prayer.asPrayer.id)
                .padding(.horizontal)
            }
            
            // 5. Apostles' Creed
            SectionHeaderView(title: "5. The Apostles' Creed")
            if let prayer = commonPrayers["apostles_creed"] {
                PrayerCardView(
                    prayer: prayer.asPrayer,
                    selectedLanguage: selectedLanguage,
                    shouldHighlight: scrollToId == prayer.asPrayer.id
                )
                .id(prayer.asPrayer.id)
                .padding(.horizontal)
            }
        }
    }
}

private struct DecadesView: View {
    let template: DivineMercyTemplate
    let commonPrayers: [String: DivineMercyPrayer]
    let selectedLanguage: PrayerLanguage
    let scrollToId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 6. The Eternal Father
            SectionHeaderView(title: "6. The Eternal Father")
            if let prayer = commonPrayers["eternal_father"] {
                PrayerCardView(
                    prayer: prayer.asPrayer,
                    selectedLanguage: selectedLanguage,
                    shouldHighlight: scrollToId == prayer.asPrayer.id
                )
                .id(prayer.asPrayer.id)
                .padding(.horizontal)
            }
            
            // 7. On the 10 Small Beads of Each Decade
            SectionHeaderView(title: "7. On the 10 Small Beads of Each Decade")
            if let prayer = commonPrayers["for_his_sorrowful_passion"] {
                PrayerCardView(
                    prayer: prayer.asPrayer,
                    selectedLanguage: selectedLanguage,
                    shouldHighlight: scrollToId == prayer.asPrayer.id
                )
                .id(prayer.asPrayer.id)
                .padding(.horizontal)
            }
            
            // 8. Repeat for remaining decades
            SectionHeaderView(title: "8. Repeat for the remaining decades")
            Text("Saying the \"Eternal Father\" on the \"Our Father\" bead and then 10 \"For the sake of His sorrowful Passion\" on the following \"Hail Mary\" beads.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
}

private struct OptionalClosingPrayersView: View {
    let selectedLanguage: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional Closing Prayer")
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 2)
            
            if selectedLanguage == .latinOnly || selectedLanguage == .bilingual {
                Text("O Deus valde Misericors, Bonitas Infinita, hodie tota humanitas de abysso miseriae suae misericordiam Tuam invocat, Tuam compassionem, o Deus; et clamat potenti voce miseriae suae. Deus benigne, ne reiicias orationem terrae huius exulum! O Domine, Bonitas, quae comprehendere non possumus, qui cognoscis miseriam nostram penitus et scis, quod viribus nostris ascendere ad Te non possumus, supplices Te rogamus: praeveni nos gratia Tua et multiplica continuo in nobis misericordiam Tuam, ut voluntatem Tuam sanctam fideliter faciamus per totam vitam et in hora mortis. Praepotentia misericordiae Tuae defendat nos a telis inimicorum salutis nostrae, ut cum fiducia, ut filii Tui, adventum ultimum Tuum exspectemus, diem Tibi soli notum. Et speramus nos assecuturos esse omnia, quae nobis promisit Iesus, non obstante tota miseria nostra. Quia Iesus spes nostra est, per Cor Eius misericordiosum, sicut per portam apertam, transimus in caelum.")
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if selectedLanguage == .englishOnly || selectedLanguage == .bilingual {
                Text("O Greatly Merciful God, Infinite Goodness, today all mankind calls out from the abyss of its misery to Your mercy — to Your compassion, O God; and it is with its mighty voice of misery that it cries out. Gracious God, do not reject the prayer of this earth's exiles! O Lord, Goodness beyond our understanding, Who are acquainted with our misery through and through, and know that by our own power we cannot ascend to You, we implore You: anticipate us with Your grace and keep on increasing Your mercy in us, that we may faithfully do Your holy will all through our life and at death's hour. Let the omnipotence of Your mercy shield us from the darts of our salvation's enemies, that we may with confidence, as Your children, await Your [Son's] final coming — that day known to You alone. And we expect to obtain everything promised us by Jesus in spite of all our wretchedness. For Jesus is our Hope: through His merciful Heart, as through an open gate, we pass through to Heaven.")
                    .font(.body)
                    .foregroundColor(selectedLanguage == .bilingual ? 
                                    (colorScheme == .dark ? .gray : .secondary) : 
                                    (colorScheme == .dark ? .white : .primary))
                    .italic(selectedLanguage == .bilingual)
                    .padding(.top, selectedLanguage == .bilingual ? 2 : 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// Helper view for prayers in the Divine Mercy
private struct PrayerCardView: View {
    let prayer: Prayer
    let selectedLanguage: PrayerLanguage
    let shouldHighlight: Bool
    
    var body: some View {
        PrayerCard(prayer: prayer, language: selectedLanguage)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(shouldHighlight ? Color.deepPurple : Color.clear, lineWidth: shouldHighlight ? 2 : 0)
            )
    }
}

// Modified RepeatedPrayerView to handle scrolling
private struct RepeatedPrayerView: View {
    let prayer: Prayer
    let count: Int
    let intentions: [String]?
    let selectedLanguage: PrayerLanguage
    let shouldHighlight: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(prayer.displayTitleEnglish) (\(count)x)")
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 2)
            
            if let intentions = intentions {
                Text("For: \(intentions.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
            
            if selectedLanguage == .latinOnly || selectedLanguage == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if selectedLanguage == .englishOnly || selectedLanguage == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(selectedLanguage == .bilingual ? 
                                    (colorScheme == .dark ? .gray : .secondary) : 
                                    (colorScheme == .dark ? .white : .primary))
                    .italic(selectedLanguage == .bilingual)
                    .padding(.top, selectedLanguage == .bilingual ? 2 : 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(shouldHighlight ? Color.deepPurple : Color.deepPurple.opacity(0.2), lineWidth: shouldHighlight ? 2 : 1)
        )
    }
}

private struct LoadingErrorView: View {
    let isLoading: Bool
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var prayerStore: PrayerStore
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.deepPurple, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: 360))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
                
                Text("Loading prayers...")
                    .font(.headline)
                    .foregroundColor(.deepPurple)
                
                Text("Preparing your spiritual journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Unable to Load Prayers")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text("Please check your connection and try again")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    prayerStore.loadPrayers()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.deepPurple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.9))
    }
}

#Preview {
    NavigationView {
        DivineMercyView()
            .environmentObject(PrayerStore())
    }
} 