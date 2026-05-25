import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @State private var churchName = ""
    @State private var teamSize = 8
    @State private var worshipStyle = WorshipStyle.contemporary
    @State private var role = PrimaryRole.worshipLeader
    @State private var notificationsEnabled = true

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WorshipFlow AI")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.white)
                        Text("The modern operating system for worship teams.")
                            .font(.title3)
                            .foregroundStyle(WFColor.softGold)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 18) {
                        TextField("Church name", text: $churchName)
                            .textFieldStyle(.roundedBorder)
                        Stepper("Team size: \(teamSize)", value: $teamSize, in: 1...200)
                            .foregroundStyle(.white)
                        Picker("Worship style", selection: $worshipStyle) {
                            ForEach(WorshipStyle.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Picker("Primary role", selection: $role) {
                            ForEach(PrimaryRole.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Toggle("Enable rehearsal and service reminders", isOn: $notificationsEnabled)
                    }
                    .pickerStyle(.menu)
                    .tint(WFColor.gold)
                    .wfPanel()

                    Text(WorshipFlowAIPrompt.disclaimer)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.64))

                    Button {
                        appModel.createOnboardingProfile(
                            context: modelContext,
                            churchName: churchName.isEmpty ? "My Church" : churchName,
                            teamSize: teamSize,
                            worshipStyle: worshipStyle,
                            role: role,
                            notificationsEnabled: notificationsEnabled
                        )
                    } label: {
                        Label("Start Planning", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(WFColor.gold)
                }
                .padding()
            }
        }
    }
}
