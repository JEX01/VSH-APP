# NTPC Photo Inspection Backend API

A secure, scalable Node.js backend for the NTPC Photo Inspection Mobile App.

## Features

- **RESTful API** with Express.js
- **PostgreSQL** database with Knex.js ORM
- **AWS S3** integration for photo storage
- **JWT Authentication** with role-based access control
- **Comprehensive Audit Logging** for all actions
- **File Upload** with automatic thumbnail generation
- **Task Management** system for workers and managers
- **Equipment Management** with QR code support
- **Real-time Notifications** via Firebase Cloud Messaging

## Tech Stack

- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Database**: PostgreSQL 14+
- **ORM**: Knex.js
- **Storage**: AWS S3
- **Authentication**: JWT
- **Image Processing**: Sharp
- **Logging**: Winston
- **Validation**: Express Validator

## Quick Start

### Prerequisites

- Node.js 16+ and npm 8+
- PostgreSQL 14+
- AWS S3 bucket
- Firebase project (for FCM)

### Installation

1. **Clone and navigate to backend directory**
   ```bash
   cd /workspace/plantvision/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Database setup**
   ```bash
   # Run migrations
   npm run migrate
   
   # Seed initial data
   npm run seed
   ```

5. **Start the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## Environment Variables

Create a `.env` file with the following variables:

```env
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ntpc_photo_inspection
DB_USER=postgres
DB_PASSWORD=your_password

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h

# AWS S3 Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
S3_BUCKET_NAME=ntpc-photo-inspection-bucket

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-firebase-client-email
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user profile
- `PUT /api/v1/auth/profile` - Update user profile
- `PUT /api/v1/auth/change-password` - Change password

### Photos
- `POST /api/v1/photos/upload` - Upload photo with metadata
- `GET /api/v1/photos` - Get photos with filtering
- `GET /api/v1/photos/:id` - Get single photo
- `PUT /api/v1/photos/:id/approve` - Approve photo (Manager)
- `PUT /api/v1/photos/:id/reject` - Reject photo (Manager)
- `DELETE /api/v1/photos/:id` - Delete photo (Manager)

### Tasks
- `POST /api/v1/tasks` - Create task (Manager)
- `GET /api/v1/tasks` - Get tasks with filtering
- `GET /api/v1/tasks/:id` - Get single task
- `PUT /api/v1/tasks/:id/status` - Update task status
- `PUT /api/v1/tasks/:id` - Update task details (Manager)
- `DELETE /api/v1/tasks/:id` - Delete task (Manager)
- `GET /api/v1/tasks/stats` - Get task statistics

### Equipment
- `GET /api/v1/equipment` - Get equipment list
- `GET /api/v1/equipment/:id` - Get single equipment
- `GET /api/v1/equipment/qr/:qrCode` - Get equipment by QR code
- `GET /api/v1/equipment/types` - Get equipment types
- `GET /api/v1/equipment/:id/photos` - Get equipment photos
- `GET /api/v1/equipment/:id/tasks` - Get equipment tasks

### Users (Manager/Admin only)
- `GET /api/v1/users` - Get users list
- `GET /api/v1/users/:id` - Get single user
- `GET /api/v1/users/workers/list` - Get workers for task assignment
- `GET /api/v1/users/:id/activity` - Get user activity
- `PUT /api/v1/users/:id/status` - Update user status
- `GET /api/v1/users/stats/overview` - Get users statistics

### Audit Logs (Manager/Admin only)
- `GET /api/v1/audit/logs` - Get audit logs
- `GET /api/v1/audit/stats` - Get audit statistics
- `GET /api/v1/audit/user/:userId` - Get user audit logs
- `GET /api/v1/audit/resource/:type/:id` - Get resource audit logs
- `POST /api/v1/audit/cleanup` - Cleanup old logs (Admin)

## Database Schema

### Users
- User authentication and profile information
- Role-based access control (worker, manager, admin)
- Plant area assignments for access control

### Plants
- Power plant facility information
- Location and contact details

### Equipment
- Equipment registry with QR codes
- Specifications and maintenance status
- Location tracking within plants

### Photos
- Photo metadata with GPS and timestamps
- S3 storage keys and thumbnails
- Approval workflow and status tracking

### Tasks
- Task assignment and tracking
- Priority levels and due dates
- Completion status and notes

### Audit Logs
- Comprehensive activity logging
- User action tracking
- Resource change history

## Security Features

- **JWT Authentication** with refresh tokens
- **Role-based Access Control** (RBAC)
- **Input Validation** and sanitization
- **Rate Limiting** to prevent abuse
- **CORS Protection** with configurable origins
- **Helmet.js** for security headers
- **AES-256 Encryption** for sensitive data
- **Audit Logging** for all actions
- **Password Hashing** with bcrypt

## File Upload

- **Multer S3** for direct S3 uploads
- **Sharp** for image processing and thumbnails
- **File Type Validation** (JPEG, PNG, WebP)
- **Size Limits** (configurable, default 10MB)
- **Checksum Verification** (SHA-256)
- **Metadata Extraction** (EXIF data)

## Error Handling

- **Global Error Handler** with detailed logging
- **Validation Errors** with field-specific messages
- **Database Errors** with user-friendly messages
- **File Upload Errors** with size and type validation
- **Authentication Errors** with proper status codes

## Logging

- **Winston Logger** with multiple transports
- **Request Logging** with Morgan
- **Error Logging** with stack traces
- **Audit Logging** to database
- **Log Rotation** and retention policies

## Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## Deployment

### Docker

```bash
# Build image
docker build -t ntpc-photo-inspection-backend .

# Run container
docker run -p 3000:3000 --env-file .env ntpc-photo-inspection-backend
```

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure production database
- [ ] Set up AWS S3 bucket with proper permissions
- [ ] Configure Firebase project for FCM
- [ ] Set strong JWT secret
- [ ] Enable SSL/TLS
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Set up CI/CD pipeline

## Default Users

After running seeds, the following test users are available:

| Username | Password | Role | Plant Area |
|----------|----------|------|------------|
| admin | admin123 | admin | All Areas |
| manager1 | manager123 | manager | Boiler Area |
| manager2 | manager123 | manager | Turbine Area |
| worker1 | worker123 | worker | Boiler Area |
| worker2 | worker123 | worker | Turbine Area |
| worker3 | worker123 | worker | Generator Area |

## API Documentation

The API follows RESTful conventions with consistent response formats:

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "details": [
    // Validation errors (if applicable)
  ]
}
```

### Pagination
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

## Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Ensure all tests pass
5. Submit pull request

## License

Proprietary - NTPC Limited. All rights reserved.

## Support

For technical support, contact the development team or create an issue in the project repository.