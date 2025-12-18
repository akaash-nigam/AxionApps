//
//  AnalyticsView.swift
//  CorporateUniversity
//
//  Complete implementation with charts, stats, and insights
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(AppModel.self) private var appModel
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showDetailedStats = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Learning Analytics")
                        .font(.system(size: 40, weight: .bold))
                    
                    Text("Track your progress and performance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Period Selector
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                
                // Stats Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    statCard(value: "12", label: "Courses\nCompleted", icon: "checkmark.circle.fill", color: .green)
                    statCard(value: "42h", label: "Learning\nTime", icon: "clock.fill", color: .blue)
                    statCard(value: "89%", label: "Average\nScore", icon: "chart.bar.fill", color: .purple)
                    statCard(value: "24", label: "Day\nStreak", icon: "flame.fill", color: .orange)
                }
                
                // Learning Time Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Learning Time")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Chart {
                        ForEach(sampleLearningData) { dataPoint in
                            BarMark(
                                x: .value("Day", dataPoint.day),
                                y: .value("Hours", dataPoint.hours)
                            )
                            .foregroundStyle(Color.accentColor.gradient)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                }
                .padding(24)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(16)
                
                // Course Progress Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Course Completion")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Chart(sampleCourseProgress, id: \.course) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Status", item.course))
                        .cornerRadius(4)
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom)
                }
                .padding(24)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(16)
                
                // Skills Progress
                VStack(alignment: .leading, spacing: 16) {
                    Text("Skills Progress")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    ForEach(sampleSkills, id: \.name) { skill in
                        skillProgressRow(skill: skill)
                    }
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activity")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        activityRow(icon: "checkmark.circle.fill", color: .green, title: "Completed Swift Basics", time: "2 hours ago")
                        activityRow(icon: "star.fill", color: .yellow, title: "Earned Achievement: Quick Learner", time: "5 hours ago")
                        activityRow(icon: "play.circle.fill", color: .blue, title: "Started Leadership Course", time: "1 day ago")
                        activityRow(icon: "bookmark.fill", color: .purple, title: "Bookmarked Data Science", time: "2 days ago")
                    }
                }
            }
            .padding(40)
        }
        .glassBackgroundEffect()
    }
    
    @ViewBuilder
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
            
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func skillProgressRow(skill: SkillData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(skill.progress))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: skill.progress, total: 100)
                .tint(skill.color)
        }
        .padding(16)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func activityRow(icon: String, color: Color, title: String, time: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                Text(time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    // Sample Data
    private var sampleLearningData: [LearningData] {
        [
            LearningData(day: "Mon", hours: 2.5),
            LearningData(day: "Tue", hours: 3.2),
            LearningData(day: "Wed", hours: 1.8),
            LearningData(day: "Thu", hours: 4.1),
            LearningData(day: "Fri", hours: 2.7),
            LearningData(day: "Sat", hours: 3.5),
            LearningData(day: "Sun", hours: 2.0)
        ]
    }
    
    private var sampleCourseProgress: [CourseProgressData] {
        [
            CourseProgressData(course: "Completed", count: 12),
            CourseProgressData(course: "In Progress", count: 5),
            CourseProgressData(course: "Not Started", count: 3)
        ]
    }
    
    private var sampleSkills: [SkillData] {
        [
            SkillData(name: "Swift Programming", progress: 85, color: .orange),
            SkillData(name: "Leadership", progress: 72, color: .blue),
            SkillData(name: "Data Analysis", progress: 60, color: .purple),
            SkillData(name: "Design Thinking", progress: 45, color: .green)
        ]
    }
}

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct LearningData: Identifiable {
    let id = UUID()
    let day: String
    let hours: Double
}

struct CourseProgressData {
    let course: String
    let count: Int
}

struct SkillData {
    let name: String
    let progress: Double
    let color: Color
}

#Preview {
    AnalyticsView()
        .environment(AppModel())
}
