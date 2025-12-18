import SwiftUI

struct PatientCard: View {
    let patient: Patient

    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            statusIndicator

            // Patient Information
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.fullName)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label("MRN: \(patient.mrn)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label("\(patient.age) yrs", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let location = patient.currentLocation {
                        Label(location, systemImage: "bed.double.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Latest Vital Signs
                if let vitals = patient.latestVitalSign {
                    VitalSignsSummary(vitalSign: vitals)
                }
            }

            Spacer()

            // Status Badge
            statusBadge
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(statusColor.opacity(0.3), lineWidth: 2)
        )
    }

    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(statusColor.opacity(0.3), lineWidth: 4)
                    .scaleEffect(patient.status == .critical ? 1.5 : 1.0)
                    .opacity(patient.status == .critical ? 0 : 1)
                    .animation(
                        patient.status == .critical ?
                            .easeInOut(duration: 1).repeatForever(autoreverses: false) : .default,
                        value: patient.status
                    )
            )
    }

    private var statusBadge: some View {
        Text(patient.status.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor)
            .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch patient.status {
        case .active: return .blue
        case .critical: return .red
        case .stable: return .green
        case .discharged: return .gray
        case .deceased: return .black
        }
    }
}

struct VitalSignsSummary: View {
    let vitalSign: VitalSign

    var body: some View {
        HStack(spacing: 12) {
            if let hr = vitalSign.heartRate {
                VitalBadge(value: "\(hr)", unit: "BPM", icon: "heart.fill", isAbnormal: hr < 60 || hr > 100)
            }

            if let bp = vitalSign.bloodPressureString {
                VitalBadge(value: bp, unit: "BP", icon: "waveform.path.ecg", isAbnormal: vitalSign.bloodPressureSystolic ?? 0 < 90)
            }

            if let spo2 = vitalSign.oxygenSaturation {
                VitalBadge(value: "\(spo2)%", unit: "SpO₂", icon: "lungs.fill", isAbnormal: spo2 < 95)
            }

            if let temp = vitalSign.temperature {
                VitalBadge(value: String(format: "%.1f", temp), unit: "°C", icon: "thermometer", isAbnormal: temp > 38.0)
            }
        }
        .font(.caption2)
    }
}

struct VitalBadge: View {
    let value: String
    let unit: String
    let icon: String
    let isAbnormal: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(isAbnormal ? .red : .secondary)
            Text("\(value)")
                .fontWeight(isAbnormal ? .semibold : .regular)
                .foregroundStyle(isAbnormal ? .red : .primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isAbnormal ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct AlertCard: View {
    let alert: ClinicalAlert
    let onAcknowledge: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Severity Indicator
            Image(systemName: severityIcon)
                .font(.title2)
                .foregroundStyle(severityColor)
                .frame(width: 40)

            // Alert Information
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.patientName)
                    .font(.headline)

                Text(alert.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(alert.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Acknowledge Button
            Button(action: onAcknowledge) {
                Label("Acknowledge", systemImage: "checkmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(severityColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(severityColor.opacity(0.3), lineWidth: 2)
        )
    }

    private var severityIcon: String {
        switch alert.severity {
        case .normal: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.circle.fill"
        case .emergency: return "alarm.fill"
        }
    }

    private var severityColor: Color {
        switch alert.severity {
        case .normal: return .blue
        case .warning: return .yellow
        case .critical: return .orange
        case .emergency: return .red
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview("Patient Card") {
    let patient = Patient.preview
    patient.vitalSigns.append(VitalSign.previewCritical)

    return PatientCard(patient: patient)
        .padding()
        .frame(width: 600)
}

#Preview("Alert Card") {
    let alert = ClinicalAlert(
        patientId: UUID(),
        patientName: "Smith, John",
        alertType: .vitalSign,
        severity: .critical,
        message: "Heart rate elevated at 125 BPM"
    )

    return AlertCard(alert: alert) {
        print("Acknowledged")
    }
    .padding()
    .frame(width: 500)
}
#endif
