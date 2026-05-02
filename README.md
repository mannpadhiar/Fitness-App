<p align="center">
  <img src="frontend/assets/playstore.png" alt="Strive Logo" width="120" height="120" style="border-radius: 24px;" />
</p>

<h1 align="center">Strive</h1>

<p align="center">
  <em>Push harder than yesterday.</em>
</p>

<p align="center">
  An AI-powered fitness & nutrition tracking app built with Flutter and Node.js.<br/>
  Track calories · Count steps · Scan food · Food Recommendation · Stay fit.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.8+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-Express%205-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Prisma-7.5-2D3748?style=for-the-badge&logo=prisma&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/AI-Powered-FF6F61?style=for-the-badge&logo=huggingface&logoColor=white" />
</p>

---

## 📖 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [How It Works](#-how-it-works)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Environment Variables](#-environment-variables)
- [API Reference](#-api-reference)
- [Project Structure](#-project-structure)
- [AI Features](#-ai-features)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🧠 About

**Strive** is a full-stack, AI-powered fitness application designed to help users take control of their health and nutrition journey. It combines intelligent food recognition, personalized nutrition recommendations, real-time step tracking, and comprehensive exercise logging — all wrapped in a sleek dark-themed UI.

Whether you're trying to lose weight, gain muscle, or simply maintain a healthier lifestyle, Strive adapts to your goals using scientifically-backed formulas (Mifflin-St Jeor BMR/TDEE) to provide personalized daily targets.

---

## ✨ Features

### AI-Powered Food Scanning
- **Snap a photo** of your food and let AI identify it instantly
- Uses a custom **HuggingFace Gradio** image classification model
- Automatically detects the food name and estimates nutritional values (calories, protein, carbs, fats)
- Supports **30+ food items** including Indian cuisine (biryani, dosa, paneer, samosa, etc.)
- Editable results — review and adjust nutrition data before saving

### Smart Food Recommendations
- AI recommends foods based on your **remaining nutritional goals** for the day
- Dynamically adapts as you log meals throughout the day
- Powered by a custom recommendation engine

### Dashboard
- At-a-glance view of your daily calorie intake with an animated **circular progress ring**
- Live calorie tracking: **Base Goal − Food + Exercise = Remaining**
- Nutrition summary showing protein, carbs, and fats breakdown
- Smart time-based greetings and motivational messages
- Quick access to your user profile via account drawer

### Food Diary
- Log meals sorted by type — **Breakfast, Lunch, Dinner, Snack**
- Detailed food breakdown with per-serving and per-100g nutritional info
- **Quick Calories** shortcut for fast logging
- Date navigation to review previous days
- Swipe-to-delete with confirmation dialog

### Step Tracking
- Real-time **pedometer** integration using device sensors
- Tracks steps from midnight using a hybrid approach (baseline + live stream delta)
- **Dynamic step goals** calculated using the Mifflin-St Jeor formula based on your age, weight, height, gender, and activity level
- Automatic calorie burn estimation from steps (weight-aware formula)
- Background sync to backend every 30 seconds

### Exercise Logging
- Built-in **stopwatch** for timing workouts
- Log exercises with name, duration, and calories burned
- Calories from exercises are automatically reflected on the dashboard
- Date-wise exercise history with swipe-to-delete
- One-tap "Log Workout" after stopping the timer

### Progress Tracking
- **Weight history** visualization with interactive line charts
- **Calorie intake vs. burned** bar chart for the last 7 days
- Track weight changes over time with start vs. current stats
- Pull-to-refresh for latest data

### User Onboarding
- Beautiful 5-step onboarding flow:
  1. **Name** — Personalize your experience
  2. **Goals** — Choose up to 3 goals (lose weight, gain muscle, modify diet, etc.)
  3. **Activity Level** — From sedentary to very active
  4. **Personal Info** — Gender, age, and country
  5. **Body Metrics** — Height and weight
- All data synced to backend on completion

### Authentication
- Secure email + password authentication
- **JWT-based** session management (30-day tokens)
- Password hashing with **bcrypt**
- Input validation with **Zod**
- Persistent login with local token storage

### Premium Dark UI
- Sleek dark theme with GitHub-inspired color palette
- **Google Fonts (Inter)** typography
- Smooth animations and transitions throughout
- Custom bottom navigation bar with floating quick-add button
- Glassmorphism-inspired card designs

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/home_screen_screenshot.png" width="180" style="border-radius: 14px; margin:10px;" />
  <img src="screenshots/diary_screenshot.png" width="180" style="border-radius: 14px; margin:10px;" />
  <img src="screenshots/food_log_screenshot.png" width="180" style="border-radius: 14px; margin:10px;" />
  <img src="screenshots/weight_log_screenshot.png" width="180" style="border-radius: 14px; margin:10px;" />
  <img src="screenshots/exercise_page_screenshot.png" width="180" style="border-radius: 14px; margin:10px;" />
</p>

<p align="center">
  <sub>✨ Track calories · Log meals · AI food scan · Monitor progress · Stay consistent</sub>
</p>

---

##  How It Works

```
┌──────────────────────────────────────────────────────────────────────┐
│                         USER FLOW                                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Sign Up / Login ─── JWT Token ───► Stored Locally                │
│          │                                                           │
│  2. Onboarding (5 steps) ──► Profile saved to backend                │
│          │                        │                                  │
│          │                  Auto-generates:                          │
│          │                  • Daily calorie target (BMR × TDEE)      │
│          │                  • Macro goals (protein/carbs/fats)       │
│          │                  • Dynamic step goal                      │
│          │                                                           │
│  3. Dashboard ◄──── Preloaded data (splash screen)                   │
│          │                                                           │
│          ├── Calorie Ring: Remaining = Goal − Food + Exercise        │
│          ├── Step Counter: Real-time pedometer + auto-sync           │
│          ├── Nutrition Summary: Protein / Carbs / Fats               │
│          └── AI Food Recommendations: Based on remaining macros      │
│                                                                      │
│  4. Food Diary ──── Log meals ──► Backend ──► Daily summary updated  │
│          │                                                           │
│  5. AI Food Scan ── Camera/Gallery ──► HuggingFace API ──► Results   │
│          │                  └── Editable ──► Save to diary            │
│          │                                                           │
│  6. Exercise ──── Stopwatch + Manual logging ──► Backend             │
│          │                                                           │
│  7. Progress ──── Weight chart + 7-day calorie chart                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

### Frontend (Mobile App)
| Technology | Purpose |
|---|---|
| **Flutter** (Dart 3.8+) | Cross-platform mobile framework |
| **GetX** | State management, routing, and dependency injection |
| **Google Fonts** | Inter font family for premium typography |
| **Pedometer 2** | Real-time step counting via device sensors |
| **FL Chart** | Beautiful weight and calorie charts |
| **Image Picker** | Camera and gallery access for food scanning |
| **Percent Indicator** | Animated circular progress rings |
| **Get Storage** | Local storage for offline data caching |
| **Flutter Dotenv** | Environment variable management |

### Backend (API Server)
| Technology | Purpose |
|---|---|
| **Node.js** + **Express 5** | REST API server |
| **TypeScript** | Type-safe backend development |
| **Prisma 7.5** | ORM for database management |
| **PostgreSQL** | Primary relational database |
| **JWT** (jsonwebtoken) | Authentication tokens |
| **bcrypt** | Password hashing |
| **Zod** | Request body validation |
| **TSX** | Hot-reload development server |

### AI / ML Services
| Service | Purpose |
|---|---|
| **HuggingFace Spaces** | Custom food image classifier (Gradio API) |
| **Food Recommendation API** | AI-powered nutritional food suggestions |

---

## 🏗 Architecture

```
fitness-app/
├── backend/                    # Node.js REST API
│   ├── prisma/
│   │   └── schema.prisma       # Database schema (8 models)
│   └── src/
│       ├── controllers/        # Route handlers (9 controllers)
│       ├── services/           # Business logic (8 services)
│       ├── routes/             # Express routers (10 route files)
│       ├── middleware/         # Auth (JWT) + Error handling
│       ├── validators/         # Zod schemas
│       └── app.ts              # Express app config
│
└── frontend/                   # Flutter mobile app
    └── lib/
        └── app/
            ├── modules/        # Feature modules (9 modules)
            │   ├── auth/       # Sign-in & sign-up screens
            │   ├── splash/     # Animated splash with data preloading
            │   ├── onboarding/ # 5-step user setup wizard
            │   ├── home/       # Dashboard with calorie ring
            │   ├── diary/      # Food diary & meal logging
            │   ├── exercise/   # Stopwatch + exercise logging
            │   ├── progress/   # Charts & weight tracking
            │   ├── nav/        # Bottom nav + quick-add FAB
            │   └── profile/    # User profile
            ├── services/       # API, auth, food AI services
            ├── theme/          # Dark theme + color system
            ├── widgets/        # Reusable UI components
            └── routes/         # GetX route definitions
```

### Database Schema

The app uses **8 database models**:

| Model | Description |
|---|---|
| `User` | User profile (name, email, age, weight, height, goals) |
| `WeightHistory` | Weight log entries over time |
| `UserGoal` | Daily calorie & macro targets |
| `Food` | Food items with per-100g nutritional data |
| `Meal` | Meal entries (breakfast, lunch, dinner, snack) |
| `MealItem` | Individual food items within a meal |
| `DailyStep` | Daily step count and calories burned |
| `DailySummary` | Aggregated daily nutrition totals |
| `Exercise` | Logged workouts with duration and calories |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter** 3.8+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Node.js** 18+ ([Install Node.js](https://nodejs.org/))
- **PostgreSQL** 14+ ([Install PostgreSQL](https://www.postgresql.org/download/))
- **Android Studio** or **VS Code** with Flutter extension
- A physical Android device or emulator

### Backend Setup

1. **Navigate to the backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the `backend/` directory:
   ```env
   DATABASE_URL="postgresql://username:password@localhost:5432/strive_db"
   JWT_SECRET="your-super-secret-jwt-key"
   PORT=3000
   ```

4. **Set up the database**
   ```bash
   # Generate Prisma client
   npx prisma generate

   # Run database migrations
   npx prisma migrate dev --name init
   ```

5. **Start the development server**
   ```bash
   npm run dev
   ```

   The API will be running at `http://localhost:3000`

6. **Verify the server**
   ```bash
   curl http://localhost:3000/api/health
   # Response: {"status":"ok","timestamp":"..."}
   ```

### Frontend Setup

1. **Navigate to the frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the `frontend/` directory:
   ```env
   BASE_URL=http://10.0.2.2:3000/api
   HF_TOKEN=your-huggingface-token
   FOOD_RECOMMENDATION_URL=http://your-recommendation-api/recommend
   ```
   
   > **Note:** `10.0.2.2` is the Android emulator's alias for `localhost`. Use your machine's IP for physical devices.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔑 Environment Variables

### Backend (`backend/.env`)

| Variable | Description | Required |
|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | ✅ |
| `JWT_SECRET` | Secret key for JWT signing | ✅ |
| `PORT` | Server port (default: 3000) | ❌ |

### Frontend (`frontend/.env`)

| Variable | Description | Required |
|---|---|---|
| `BASE_URL` | Backend API base URL | ✅ |
| `HF_TOKEN` | HuggingFace API token for food scanning | ❌ |
| `FOOD_RECOMMENDATION_URL` | Food recommendation API endpoint | ❌ |

---

## 📡 API Reference

### Authentication (Public)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register a new user |
| `POST` | `/api/auth/login` | Login and receive JWT |

### User Management
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users/:id` | Get user profile |
| `PUT` | `/api/users/:id` | Update user profile |

### Meals & Food
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/users/:userId/meals` | Create a new meal |
| `GET` | `/api/users/:userId/meals?date=YYYY-MM-DD` | Get meals for a date |
| `DELETE` | `/api/meals/:id` | Delete a meal |
| `GET` | `/api/foods/search?q=name` | Search food database |

### Exercise
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/users/:userId/exercises` | Log an exercise |
| `GET` | `/api/users/:userId/exercises?date=YYYY-MM-DD` | Get exercises for a date |
| `DELETE` | `/api/exercises/:id` | Delete an exercise |

### Steps & Summary
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/users/:userId/daily-steps` | Upsert daily step count |
| `GET` | `/api/users/:userId/daily-summary?date=YYYY-MM-DD` | Get daily nutrition summary |
| `GET` | `/api/users/:userId/daily-summary/range?from=...&to=...` | Get summary range |

### Weight & Goals
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/users/:userId/weight-history` | Log weight entry |
| `GET` | `/api/users/:userId/weight-history` | Get weight history |
| `GET` | `/api/users/:userId/goals` | Get active nutrition goals |

### Health Check
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/health` | Server status check |

> 🔒 All endpoints except `/api/auth/*` and `/api/health` require a `Bearer` JWT token in the `Authorization` header.

---

## 🧬 Project Structure

<details>
<summary><strong>Backend — Full File Tree</strong></summary>

```
backend/
├── .env                              # Environment variables
├── .gitignore
├── package.json
├── tsconfig.json
├── prisma.config.ts
├── prisma/
│   └── schema.prisma                 # 8 database models
└── src/
    ├── app.ts                        # Express app setup
    ├── index.ts                      # Server entry point
    ├── prisma.ts                     # Prisma client singleton
    ├── controllers/
    │   ├── auth.controller.ts        # Register + Login
    │   ├── user.controller.ts        # User CRUD
    │   ├── meal.controller.ts        # Meal + MealItem CRUD
    │   ├── food.controller.ts        # Food search + creation
    │   ├── exercise.controller.ts    # Exercise logging
    │   ├── dailyStep.controller.ts   # Step upsert
    │   ├── dailySummary.controller.ts# Daily nutrition aggregation
    │   ├── userGoal.controller.ts    # Calorie & macro targets
    │   └── weightHistory.controller.ts# Weight tracking
    ├── services/
    │   ├── user.service.ts           # User business logic + BMR/TDEE
    │   ├── meal.service.ts           # Meal creation with auto-summary
    │   ├── food.service.ts           # Food lookup/creation
    │   ├── exercise.service.ts       # Exercise CRUD + calorie sync
    │   ├── dailyStep.service.ts      # Step upsert logic
    │   ├── dailySummary.service.ts   # Summary aggregation engine
    │   ├── userGoal.service.ts       # Goal management
    │   └── weightHistory.service.ts  # Weight log service
    ├── routes/
    │   ├── index.ts                  # Route aggregator
    │   ├── auth.routes.ts
    │   ├── user.routes.ts
    │   ├── meal.routes.ts
    │   ├── food.routes.ts
    │   ├── exercise.routes.ts
    │   ├── dailyStep.routes.ts
    │   ├── dailySummary.routes.ts
    │   ├── userGoal.routes.ts
    │   └── weightHistory.routes.ts
    ├── middleware/
    │   ├── auth.ts                   # JWT verification middleware
    │   └── errorHandler.ts           # Global error handler
    └── validators/
        └── index.ts                  # Zod validation schemas
```

</details>

<details>
<summary><strong>Frontend — Full File Tree</strong></summary>

```
frontend/
├── .env                              # API URLs + tokens
├── pubspec.yaml                      # Flutter dependencies
├── assets/
│   ├── playstore.png                 # App logo
│   └── splish_screen.png             # Splash branding
└── lib/
    ├── main.dart                     # App entry point
    └── app/
        ├── modules/
        │   ├── splash/
        │   │   ├── views/splash_view.dart        # Animated splash screen
        │   │   └── controllers/splash_controller.dart
        │   ├── auth/
        │   │   └── views/sign_in_view.dart        # Login + Sign Up
        │   ├── onboarding/
        │   │   ├── views/
        │   │   │   ├── onboarding_view.dart       # PageView container
        │   │   │   ├── name_view.dart             # Step 1: Name
        │   │   │   ├── goals_view.dart            # Step 2: Goals
        │   │   │   ├── activity_view.dart         # Step 3: Activity
        │   │   │   ├── personal_info_view.dart    # Step 4: Gender/Age
        │   │   │   └── body_info_view.dart         # Step 5: Height/Weight
        │   │   └── controllers/onboarding_controller.dart
        │   ├── home/
        │   │   ├── views/home_view.dart           # Dashboard UI
        │   │   └── controllers/home_controller.dart
        │   ├── diary/
        │   │   ├── views/diary_view.dart           # Food diary
        │   │   └── controllers/diary_controller.dart
        │   ├── exercise/
        │   │   ├── views/exercise_view.dart        # Stopwatch + log
        │   │   └── controllers/exercise_controller.dart
        │   ├── progress/
        │   │   └── views/progress_view.dart        # Charts + weight log
        │   ├── nav/
        │   │   └── views/main_nav_view.dart        # Bottom nav + quick add
        │   └── profile/
        │       └── views/profile_view.dart
        ├── services/
        │   ├── api_service.dart                    # HTTP client wrapper
        │   ├── auth_service.dart                   # Token management
        │   ├── user_service.dart                   # User API calls
        │   ├── daily_service.dart                  # Steps & summary APIs
        │   ├── data_preload_service.dart           # Splash data loading
        │   ├── food_recognition_service.dart       # AI food scanning
        │   └── food_recommendation_service.dart    # AI food suggestions
        ├── theme/
        │   └── app_theme.dart                     # Colors, typography, components
        ├── widgets/
        │   ├── onboarding_scaffold.dart           # Reusable onboarding layout
        │   └── option_tile.dart                   # Selection tile widget
        └── routes/
            ├── app_routes.dart                    # Route name constants
            └── app_pages.dart                     # Route → Page bindings
```

</details>

---

## 🤖 AI Features

### Food Image Recognition

Strive uses a **custom-trained food image classification model** hosted on HuggingFace Spaces. The recognition pipeline works as follows:

1. **Capture** — User takes a photo or selects from gallery
2. **Upload** — Image is uploaded to the Gradio API endpoint
3. **Classify** — The AI model identifies the food item
4. **Enrich** — Nutritional data is estimated from a built-in database of 60+ foods
5. **Review** — User can edit the detected name, meal type, quantity, and nutrition
6. **Save** — Entry is saved to the food diary with full macro tracking

### Smart Food Recommendations

The recommendation engine analyzes your:
- **Target macros** (calories, carbs, protein, fats)
- **Already consumed** amounts for the day
- **Remaining nutritional gaps**

It then suggests foods that best fill those gaps, helping you hit your daily targets.

### Dynamic Goal Calculation

Strive uses the **Mifflin-St Jeor equation** to calculate personalized targets:

```
BMR (Male)   = 10 × weight(kg) + 6.25 × height(cm) − 5 × age + 5
BMR (Female) = 10 × weight(kg) + 6.25 × height(cm) − 5 × age − 161

TDEE = BMR × Activity Multiplier
  • Low:      1.20
  • Moderate:  1.55
  • High:      1.725

Target = TDEE ± Goal Adjustment
  • Lose:     −500 kcal
  • Maintain:  0
  • Gain:     +500 kcal
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the **ISC License**. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ using Flutter & Node.js<br/>
  <strong>Strive</strong> — Push harder than yesterday.
</p>
