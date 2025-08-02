ThinkAI
ThinkAI is an innovative iOS application designed to spark your creativity and assist you in generating new ideas, story beginnings, poetry lines, or brainstorming lists. Powered by the Google Gemini API, ThinkAI transforms your keywords and prompts into unique and inspiring textual content.

✨ Features
AI-Powered Idea Generation: Simply input your keywords or a short prompt, and let Gemini's advanced AI generate creative text for you.

Seamless Sharing: Easily share the generated ideas with friends, colleagues, or other applications using the built-in sharing functionality.

PDF Export: Convert your generated content into a professional PDF document, perfect for saving, printing, or sharing as a file.

Intuitive User Interface: A clean and user-friendly interface built with SwiftUI for a smooth experience.

🚀 Getting Started
Follow these steps to get ThinkAI up and running on your local machine.

Prerequisites

Xcode: Make sure you have Xcode installed on your macOS machine. You can download it from the Mac App Store.

Google Gemini API Key: ThinkAI relies on the Google Gemini API for content generation. You'll need to obtain your own API key.

Go to Google AI Studio.

Sign in with your Google account.

Click on "Get API key" or "Create API Key" to generate a new key.

Copy your generated API key.

Installation

Clone the Repository:

git clone https://github.com/ChiefVenzox/ThinkAI.git
cd ThinkAI

Open in Xcode:
Open the ThinkAI.xcodeproj file in Xcode.

Configure API Key:

In Xcode's Project Navigator, locate the APIKeys.swift file.

Open APIKeys.swift and replace "YOUR_GEMINI_API_KEY_HERE" with the API key you obtained from Google AI Studio.

// APIKeys.swift
struct APIKeys {
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY_HERE" // Paste your API key here
}

Important: The APIKeys.swift file is intentionally ignored by Git (via .gitignore) to prevent your API key from being publicly exposed on GitHub. Never commit your API key directly to a public repository!

🏃 How to Run
Select a Simulator: In Xcode, choose an iOS simulator (e.g., iPhone 15 Pro) from the scheme selector at the top of the window.

Build and Run: Click the "Run" button (▶️) in the Xcode toolbar, or press ⌘R.

The app will launch in the simulator. Enter your prompt in the text field and tap "Generate Idea" to see the AI in action!

🤝 Contributing
Contributions are welcome! If you have suggestions for improvements, bug fixes, or new features, please feel free to open an issue or submit a pull request.

