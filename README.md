# CalTrack

A Flutter project for tracking calories and nutrition.

## Getting Started

This project uses environment variables for sensitive configuration like Firebase API keys.

### Environment Setup for Team Members

1. **Create your .env file**:
   - Copy the `.env.example` file and rename it to `.env`
   - Ask the project admin for the actual values to use in your `.env` file
   - Never commit your `.env` file to git

```bash
cp .env.example .env
# Then edit .env with the actual values
```

2. **Install dependencies**:

```bash
flutter pub get
```

3. **Run the app**:

```bash
flutter run
```

## Security Best Practices

- **API Keys**: All API keys are stored in the `.env` file, which is excluded from git
- **Firebase Security**: Make sure to configure Firebase Security Rules for your collections
- **Authentication**: Use Firebase Authentication for user management

## Development Guidelines

- Always use the environment variables for configuration, never hardcode sensitive values
- Configure proper Firebase Security Rules to control access to your data
- Use Firebase Auth to authenticate users before allowing access to data
- Run security audits periodically using Firebase Security Rules Playground

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter DotEnv Package](https://pub.dev/packages/flutter_dotenv)
