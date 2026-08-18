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
  "Python" => { status: "practicing", description: "General-purpose programming language used throughout the degree." },
  "Mathematics" => { status: "learning", description: "Linear algebra, calculus, probability, and statistics foundations." },
  "Machine Learning" => { status: "learning", description: "Core ML algorithms and concepts." },
  "Deep Learning" => { status: "not_started", description: "Neural networks and deep learning architectures." },
  "Data Science" => { status: "not_started", description: "Data analysis, visualization, and applied statistics." },
  "Generative AI" => { status: "learning", description: "LLMs, prompting, and generative model applications." },
  "AI Agents" => { status: "not_started", description: "Autonomous and tool-using AI agents." },
  "DSA" => { status: "practicing", description: "Data structures and algorithms for problem solving." }
}

subjects = subject_definitions.each_with_object({}) do |(name, attrs), memo|
  subject = Subject.find_or_create_by!(name: name) do |s|
    s.status = attrs[:status]
    s.description = attrs[:description]
  end
  memo[name] = subject

  DegreeSubject.find_or_create_by!(degree: ai_ml_degree, subject: subject)
end

puts "Seeding courses..."
course_definitions = [
  # Python has a full roadmap: a completed course, the current one, and a planned one.
  {
    subject: "Python",
    title: "Python Basics",
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
    purpose: "Complete Python E1 foundation",
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
  {
    subject: "Machine Learning",
    title: "Machine Learning",
    provider: "Coursera (Andrew Ng)",
    status: "in_progress",
    level: "E1",
    purpose: "Machine Learning E1",
    progress_percentage: 30,
    roadmap_position: nil
  },
  {
    subject: "Generative AI",
    title: "Generative AI for Everyone",
    provider: "Coursera",
    status: "in_progress",
    level: "E2",
    purpose: "Generative AI E2",
    progress_percentage: 65,
    roadmap_position: nil
  },
  {
    subject: "DSA",
    title: "Data Structures & Algorithms in Python",
    provider: "Self-study",
    status: "planned",
    level: "E1",
    purpose: "Sharpen problem solving for technical interviews",
    progress_percentage: nil,
    roadmap_position: nil
  },
  {
    subject: "Deep Learning",
    title: "Deep Learning Specialization",
    provider: "Coursera",
    status: "planned",
    level: "E2",
    purpose: "Prepare for Deep Learning",
    progress_percentage: nil,
    roadmap_position: nil
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
  course.update!(purpose: attrs[:purpose]) if course.purpose.blank?
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
