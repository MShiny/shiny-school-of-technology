# This file should ensure the existence of records required to run the application in every environment.
# It is safe to rerun: existing records are found and reused rather than duplicated.

puts "Seeding default settings..."
unless AppSetting.exists?
  AppSetting.create!(default_daily_goal: "Study or practice at least one learning topic today.")
end

puts "Seeding degree..."
ai_ml_degree = Degree.find_or_create_by!(name: "AI/ML Degree") do |degree|
  degree.description = "A self-directed path into machine learning, deep learning, and applied AI."
  degree.status = "active"
end

puts "Seeding subjects..."
subject_definitions = {
  "Python" => { status: "learning", description: "General-purpose programming language used throughout the degree." },
  "Mathematics" => { status: "learning", description: "Linear algebra, calculus, probability, and statistics foundations." },
  "Machine Learning" => { status: "learning", description: "Core ML algorithms and concepts." },
  "Deep Learning" => { status: "learning", description: "Neural networks and deep learning architectures." },
  "Data Science" => { status: "learning", description: "Data analysis, visualization, and applied statistics." },
  "Generative AI" => { status: "learning", description: "LLMs, prompting, and generative model applications." },
  "AI Agents" => { status: "learning", description: "Autonomous and tool-using AI agents." },
  "DSA" => { status: "learning", description: "Data structures and algorithms for problem solving." }
}

subjects = subject_definitions.each_with_object({}) do |(name, attrs), memo|
  subject = Subject.find_or_create_by!(name: name) do |s|
    s.status = attrs[:status]
    s.description = attrs[:description]
  end

  # Subject status reflects where the curriculum currently stands, so it's
  # kept in sync directly (unlike course-level fields such as purpose or
  # roadmap_position, which are left alone once a user sets them).
  subject.update!(status: attrs[:status]) if subject.status != attrs[:status]
  memo[name] = subject

  DegreeSubject.find_or_create_by!(degree: ai_ml_degree, subject: subject)
end

puts "Migrating renamed demo courses to match the current curriculum naming..."
course_renames = [
  { subject: "Python", from_title: "Python Basics", to_title: "Python E0" },
  { subject: "Machine Learning", from_title: "Machine Learning", to_title: "Machine Learning E1" },
  { subject: "Generative AI", from_title: "Generative AI for Everyone", to_title: "Generative AI E2" }
]

course_renames.each do |rename|
  subject = subjects.fetch(rename[:subject])
  course = subject.courses.find_by(title: rename[:from_title])
  course&.update!(title: rename[:to_title])
end

# One-time refresh of demo purpose text being clarified in this update.
# Guarded on the exact previous placeholder text so a purpose the user has
# since edited by hand is never overwritten.
puts "Refreshing demo purpose text for current courses..."
purpose_refreshes = [
  { subject: "Python", title: "Programming for Everybody", from_purpose: "Complete Python E1 foundation", to_purpose: "Build Python fundamentals for AI/ML work" },
  { subject: "Machine Learning", title: "Machine Learning E1", from_purpose: "Machine Learning E1", to_purpose: "Build deeper machine-learning understanding" }
]

purpose_refreshes.each do |refresh|
  subject = subjects.fetch(refresh[:subject])
  course = subject.courses.find_by(title: refresh[:title])
  course.update!(purpose: refresh[:to_purpose]) if course && course.purpose == refresh[:from_purpose]
end

puts "Seeding courses..."
course_definitions = [
  # Python: E0 completed -> E1 current -> E2 planned.
  {
    subject: "Python",
    title: "Python E0",
    provider: "freeCodeCamp",
    status: "completed",
    level: "E0",
    purpose: "Warm up before the formal Python course",
    progress_percentage: 100,
    roadmap_position: 1
  },
  {
    subject: "Python",
    title: "Programming for Everybody",
    provider: "Coursera",
    status: "in_progress",
    level: "E1",
    purpose: "Build Python fundamentals for AI/ML work",
    progress_percentage: 45,
    roadmap_position: 2
  },
  {
    subject: "Python",
    title: "Advanced Python",
    provider: "Real Python",
    status: "planned",
    level: "E2",
    purpose: "Deepen Python skills for AI tooling",
    progress_percentage: nil,
    roadmap_position: 3
  },

  # Machine Learning: E0 completed -> E1 current.
  {
    subject: "Machine Learning",
    title: "Machine Learning E0",
    provider: "Coursera (Andrew Ng)",
    status: "completed",
    level: "E0",
    purpose: nil,
    progress_percentage: 100,
    roadmap_position: 1
  },
  {
    subject: "Machine Learning",
    title: "Machine Learning E1",
    provider: "Coursera (Andrew Ng)",
    status: "in_progress",
    level: "E1",
    purpose: "Build deeper machine-learning understanding",
    progress_percentage: 30,
    roadmap_position: 2
  },

  # Generative AI: E1 completed -> E2 current.
  {
    subject: "Generative AI",
    title: "Generative AI E1",
    provider: "Coursera",
    status: "completed",
    level: "E1",
    purpose: nil,
    progress_percentage: 100,
    roadmap_position: 1
  },
  {
    subject: "Generative AI",
    title: "Generative AI E2",
    provider: "Coursera",
    status: "in_progress",
    level: "E2",
    purpose: "Generative AI E2",
    progress_percentage: 65,
    roadmap_position: 2
  },

  # AI Agents: just getting started.
  {
    subject: "AI Agents",
    title: "AI Agents E0",
    provider: nil,
    status: "in_progress",
    level: "E0",
    purpose: nil,
    progress_percentage: nil,
    roadmap_position: 1
  },

  # Data Science: just getting started.
  {
    subject: "Data Science",
    title: "Data Science E0",
    provider: nil,
    status: "in_progress",
    level: "E0",
    purpose: nil,
    progress_percentage: nil,
    roadmap_position: 1
  },

  # Deep Learning: no current activity yet for this subject, so the
  # foundational course is queued up as planned rather than in_progress.
  {
    subject: "Deep Learning",
    title: "Deep Learning E0",
    provider: nil,
    status: "planned",
    level: "E0",
    purpose: nil,
    progress_percentage: nil,
    roadmap_position: 1
  },
  {
    subject: "Deep Learning",
    title: "Deep Learning Specialization",
    provider: "Coursera",
    status: "planned",
    level: "E2",
    purpose: "Prepare for Deep Learning",
    progress_percentage: nil,
    roadmap_position: 2
  },

  # Mathematics: current focus.
  {
    subject: "Mathematics",
    title: "Mathematics for Machine Learning",
    provider: nil,
    status: "in_progress",
    level: nil,
    purpose: nil,
    progress_percentage: nil,
    roadmap_position: 1
  },

  # DSA: active practice now, formal course queued up after.
  {
    subject: "DSA",
    title: "DSA Practice",
    provider: nil,
    status: "in_progress",
    level: nil,
    purpose: nil,
    progress_percentage: nil,
    roadmap_position: 1
  },
  {
    subject: "DSA",
    title: "Data Structures & Algorithms in Python",
    provider: "Self-study",
    status: "planned",
    level: "E1",
    purpose: "Sharpen problem solving for technical interviews",
    progress_percentage: nil,
    roadmap_position: 2
  }
]

course_definitions.each do |attrs|
  subject = subjects.fetch(attrs[:subject])
  course = Course.find_or_create_by!(subject: subject, title: attrs[:title]) do |c|
    c.provider = attrs[:provider]
    c.status = attrs[:status]
    c.level = attrs[:level]
    c.purpose = attrs[:purpose]
    c.progress_percentage = attrs[:progress_percentage]
    c.roadmap_position = attrs[:roadmap_position]
  end

  # Backfill fields added after this course was first seeded, without
  # touching values the user may have already entered themselves.
  course.update!(purpose: attrs[:purpose]) if course.purpose.blank? && attrs[:purpose].present?
  course.update!(progress_percentage: attrs[:progress_percentage]) if course.progress_percentage.blank? && attrs[:progress_percentage].present?
  course.update!(roadmap_position: attrs[:roadmap_position]) if course.roadmap_position.blank? && attrs[:roadmap_position].present?
end

puts "Seeding personal projects..."
lms_rag_project = PersonalProject.find_or_create_by!(name: "LMS RAG Project") do |project|
  project.status = "in_progress"
  project.goal = "Build a working RAG prototype that creates lesson plans from uploaded study material."
  project.description = "A personal learning-management side project combining retrieval-augmented generation with course content."
end

[ "Python", "Generative AI", "AI Agents" ].each do |subject_name|
  subject = subjects.fetch(subject_name)
  PersonalProjectSubject.find_or_create_by!(personal_project: lms_rag_project, subject: subject)
end

puts "Seeding daily goals..."
daily_goal_history = [
  { days_ago: 7, status: "met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 6, status: "met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 5, status: "not_met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 4, status: "met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 3, status: "met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 2, status: "met", goal_text: "Study or practice at least one learning topic today." },
  { days_ago: 1, status: "met", goal_text: "Study or practice at least one learning topic today." }
]

daily_goal_history.each do |attrs|
  date = Date.current - attrs[:days_ago].days
  DailyGoal.find_or_create_by!(date: date) do |goal|
    goal.goal_text = attrs[:goal_text]
    goal.status = attrs[:status]
  end
end

puts "Seed data ready."
