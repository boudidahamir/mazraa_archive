# Mazraa Archive Management System

This project consists of three main components:
1. BackOffice (Symfony)
2. Mobile App (Flutter)
3. Backend API (Spring Boot)

## Prerequisites

- PHP 8.1 or higher
- Composer
- Node.js and npm
- Java 17 or higher
- Maven
- Flutter SDK
- SQL Server (SSMS)
- Android Studio (for mobile development)

## BackOffice Setup (Symfony)

1. Navigate to the BackOffice directory:
```bash
cd mazraa-archive-backoffice
```

2. Install dependencies:
```bash
composer install
```

3. Configure the database in `.env`:
```env
DATABASE_URL="sqlsrv://server=localhost;database=YOUR_DATABSE;user=USERADMIN;password=YOUR_PASSWORD"
APP_SECRET=yoursecret
API_BASE_URL=http://localhost:8081
APP_ENV=dev
APP_DEBUG=1
```


4. Create an admin user:
```bash
php bin/console app:create-admin admin@mazraa.com password
```

5. Start the development server:
```bash
symfony server:start
```

The BackOffice will be available at: http://localhost:8000

## Backend API Setup (Spring Boot)

1. Navigate to the backend directory:
```bash
cd mazraa-archive-backend
```

2. Configure the database in `application.properties`:
```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=mazraa_archive
spring.datasource.username=sa
spring.datasource.password=your_password
```

3. Build the project:
```bash
mvn clean install
```

4. Run the application:
```bash
mvn spring-boot:run
```

The API will be available at: http://localhost:8080

## Mobile App Setup (Flutter)

1. Navigate to the mobile directory:
```bash
cd mazraa-archive-mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure the API URL in `lib/config/api_config.dart`:
```dart
const String baseUrl = 'http://localhost:8080/api';
```

4. Run the app:
```bash
flutter run
```

## Development Workflow

1. Start the Backend API first
2. Start the BackOffice
3. Run the mobile app

## Testing

### BackOffice
- Access http://localhost:8000
- Login with admin credentials
- Test document and storage location management

### Mobile App
- Install the app on an Android device
- Test barcode scanning and document management
- Verify offline functionality

### API
- Test endpoints using Postman or curl
- Verify synchronization between mobile and backend

## Troubleshooting

### Common Issues

1. Database Connection
- Verify SQL Server is running
- Check connection strings in both BackOffice and Backend
- Ensure firewall allows connections

2. Mobile App
- Check API URL configuration
- Verify camera permissions
- Test barcode scanning in different lighting conditions

3. BackOffice
- Clear cache if changes don't reflect: `php bin/console cache:clear`
- Check logs: `var/log/dev.log`

## Support

For technical support or questions, please contact:
- Email: support@mazraa.com
- Phone: +XXX XXX XXX XXX 