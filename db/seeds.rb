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
  {
    subject: "Python",
    title: "Programming for Everybody",
    provider: "Coursera",
    status: "in_progress",
    level: "E1",
    progress_percentage: 45
  },
  {
    subject: "Machine Learning",
    title: "Machine Learning",
    provider: "Coursera (Andrew Ng)",
    status: "in_progress",
    level: "E1",
    progress_percentage: 30
  },
  {
    subject: "Generative AI",
    title: "Generative AI for Everyone",
    provider: "Coursera",
    status: "in_progress",
    level: "E2",
    progress_percentage: 65
  },
  {
    subject: "DSA",
    title: "Data Structures & Algorithms in Python",
    provider: "Self-study",
    status: "planned",
    level: "E1",
    progress_percentage: nil
  },
  {
    subject: "Deep Learning",
    title: "Deep Learning Specialization",
    provider: "Coursera",
    status: "planned",
    level: "E2",
    progress_percentage: nil
  }
]

course_definitions.each do |attrs|
  subject = subjects.fetch(attrs[:subject])
  Course.find_or_create_by!(subject: subject, title: attrs[:title]) do |course|
    course.provider = attrs[:provider]
    course.status = attrs[:status]
    course.level = attrs[:level]
    course.progress_percentage = attrs[:progress_percentage]
  end
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
