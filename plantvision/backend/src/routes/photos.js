const express = require('express');
const multer = require('multer');
const multerS3 = require('multer-s3');
const AWS = require('aws-sdk');
const sharp = require('sharp');
const crypto = require('crypto');
const { body, query, validationResult } = require('express-validator');
const db = require('../database/connection');
const { authenticateToken, requireManager } = require('../middleware/auth');
const auditLogger = require('../utils/auditLogger');
const logger = require('../utils/logger');

const router = express.Router();

// Configure AWS S3
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

// Configure multer for S3 upload
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.S3_BUCKET_NAME,
    metadata: function (req, file, cb) {
      cb(null, {
        fieldName: file.fieldname,
        uploadedBy: req.user.id,
        uploadedAt: new Date().toISOString()
      });
    },
    key: function (req, file, cb) {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const key = `${process.env.S3_PHOTOS_PREFIX}${uniqueSuffix}-${file.originalname}`;
      cb(null, key);
    }
  }),
  limits: {
    fileSize: (parseInt(process.env.MAX_FILE_SIZE_MB) || 10) * 1024 * 1024 // Default 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = (process.env.ALLOWED_IMAGE_TYPES || 'image/jpeg,image/png,image/webp').split(',');
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`Invalid file type. Allowed types: ${allowedTypes.join(', ')}`), false);
    }
  }
});

// Generate thumbnail and upload to S3
const generateThumbnail = async (s3Key, originalBuffer) => {
  try {
    const thumbnailBuffer = await sharp(originalBuffer)
      .resize(
        parseInt(process.env.THUMBNAIL_WIDTH) || 256,
        parseInt(process.env.THUMBNAIL_HEIGHT) || 256,
        { fit: 'cover' }
      )
      .jpeg({ quality: parseInt(process.env.THUMBNAIL_QUALITY) || 80 })
      .toBuffer();

    const thumbnailKey = s3Key.replace(process.env.S3_PHOTOS_PREFIX, process.env.S3_THUMBNAILS_PREFIX);
    
    await s3.upload({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: thumbnailKey,
      Body: thumbnailBuffer,
      ContentType: 'image/jpeg'
    }).promise();

    return thumbnailKey;
  } catch (error) {
    logger.error('Thumbnail generation failed:', error);
    return null;
  }
};

// Calculate file checksum
const calculateChecksum = (buffer) => {
  return crypto.createHash('sha256').update(buffer).digest('hex');
};

// @route   POST /api/v1/photos/upload
// @desc    Upload photo with metadata
// @access  Private
router.post('/upload', authenticateToken, upload.single('photo'), [
  body('equipmentId').isUUID().withMessage('Valid equipment ID is required'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude is required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude is required'),
  body('gpsAccuracy').optional().isFloat({ min: 0 }).withMessage('GPS accuracy must be a positive number'),
  body('capturedAt').isISO8601().withMessage('Valid capture timestamp is required'),
  body('notes').optional().isLength({ max: 1000 }).withMessage('Notes cannot exceed 1000 characters'),
  body('deviceInfo').optional().isLength({ max: 255 }).withMessage('Device info cannot exceed 255 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'Photo file is required'
      });
    }

    const {
      equipmentId,
      latitude,
      longitude,
      gpsAccuracy,
      capturedAt,
      notes,
      deviceInfo
    } = req.body;

    // Verify equipment exists and user has access
    const equipment = await db('equipment')
      .select('equipment.*', 'plants.plant_code')
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('equipment.id', equipmentId)
      .first();

    if (!equipment) {
      return res.status(404).json({
        success: false,
        error: 'Equipment not found'
      });
    }

    // Check if worker has access to this plant area (if role-based restrictions apply)
    if (req.user.role === 'worker' && req.user.plantArea && req.user.plantArea !== equipment.location_area) {
      return res.status(403).json({
        success: false,
        error: 'Access denied to this equipment'
      });
    }

    // Get file buffer for checksum and thumbnail generation
    const fileBuffer = await s3.getObject({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: req.file.key
    }).promise().then(data => data.Body);

    // Calculate checksum
    const checksum = calculateChecksum(fileBuffer);

    // Generate thumbnail
    const thumbnailKey = await generateThumbnail(req.file.key, fileBuffer);

    // Get image dimensions
    const metadata = await sharp(fileBuffer).metadata();

    // Save photo record to database
    const photoData = {
      user_id: req.user.id,
      equipment_id: equipmentId,
      filename: req.file.originalname,
      original_filename: req.file.originalname,
      s3_key: req.file.key,
      thumbnail_s3_key: thumbnailKey,
      mime_type: req.file.mimetype,
      file_size: req.file.size,
      width: metadata.width,
      height: metadata.height,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      gps_accuracy: gpsAccuracy ? parseFloat(gpsAccuracy) : null,
      captured_at: new Date(capturedAt),
      device_info: deviceInfo,
      notes: notes,
      checksum: checksum,
      metadata: JSON.stringify({
        exif: metadata.exif,
        format: metadata.format,
        density: metadata.density
      })
    };

    const [photoId] = await db('photos').insert(photoData).returning('id');

    // Log photo upload
    await auditLogger.log({
      userId: req.user.id,
      action: 'CREATE',
      resourceType: 'photo',
      resourceId: photoId,
      newValues: photoData,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.status(201).json({
      success: true,
      data: {
        id: photoId,
        message: 'Photo uploaded successfully'
      }
    });
  } catch (error) {
    logger.error('Photo upload error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload photo'
    });
  }
});

// @route   GET /api/v1/photos
// @desc    Get photos with filtering and pagination
// @access  Private
router.get('/', authenticateToken, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('equipmentId').optional().isUUID().withMessage('Equipment ID must be a valid UUID'),
  query('status').optional().isIn(['pending', 'approved', 'rejected']).withMessage('Invalid status'),
  query('startDate').optional().isISO8601().withMessage('Start date must be a valid ISO date'),
  query('endDate').optional().isISO8601().withMessage('End date must be a valid ISO date'),
  query('userId').optional().isUUID().withMessage('User ID must be a valid UUID')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const {
      page = 1,
      limit = 20,
      equipmentId,
      status,
      startDate,
      endDate,
      userId
    } = req.query;

    const offset = (page - 1) * limit;

    let query = db('photos')
      .select(
        'photos.*',
        'users.username',
        'users.first_name',
        'users.last_name',
        'equipment.equipment_code',
        'equipment.equipment_name',
        'equipment.equipment_type',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('users', 'photos.user_id', 'users.id')
      .join('equipment', 'photos.equipment_id', 'equipment.id')
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('photos.status', '!=', 'deleted')
      .orderBy('photos.created_at', 'desc');

    // Role-based filtering
    if (req.user.role === 'worker') {
      // Workers can only see their own photos
      query = query.where('photos.user_id', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      // Managers can see photos from their plant area
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    // Apply filters
    if (equipmentId) {
      query = query.where('photos.equipment_id', equipmentId);
    }

    if (status) {
      query = query.where('photos.status', status);
    }

    if (startDate) {
      query = query.where('photos.captured_at', '>=', new Date(startDate));
    }

    if (endDate) {
      query = query.where('photos.captured_at', '<=', new Date(endDate));
    }

    if (userId && req.user.role !== 'worker') {
      query = query.where('photos.user_id', userId);
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('photos.id as count');

    // Get paginated results
    const photos = await query.limit(limit).offset(offset);

    // Generate signed URLs for photos and thumbnails
    const photosWithUrls = await Promise.all(photos.map(async (photo) => {
      const photoUrl = await s3.getSignedUrlPromise('getObject', {
        Bucket: process.env.S3_BUCKET_NAME,
        Key: photo.s3_key,
        Expires: 3600 // 1 hour
      });

      let thumbnailUrl = null;
      if (photo.thumbnail_s3_key) {
        thumbnailUrl = await s3.getSignedUrlPromise('getObject', {
          Bucket: process.env.S3_BUCKET_NAME,
          Key: photo.thumbnail_s3_key,
          Expires: 3600 // 1 hour
        });
      }

      return {
        ...photo,
        photo_url: photoUrl,
        thumbnail_url: thumbnailUrl,
        metadata: photo.metadata ? JSON.parse(photo.metadata) : {}
      };
    }));

    res.json({
      success: true,
      data: {
        photos: photosWithUrls,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(total),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get photos error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve photos'
    });
  }
});

// @route   GET /api/v1/photos/:id
// @desc    Get single photo by ID
// @access  Private
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    let query = db('photos')
      .select(
        'photos.*',
        'users.username',
        'users.first_name',
        'users.last_name',
        'equipment.equipment_code',
        'equipment.equipment_name',
        'equipment.equipment_type',
        'equipment.location_area',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('users', 'photos.user_id', 'users.id')
      .join('equipment', 'photos.equipment_id', 'equipment.id')
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('photos.id', id)
      .where('photos.status', '!=', 'deleted');

    // Role-based access control
    if (req.user.role === 'worker') {
      query = query.where('photos.user_id', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    const photo = await query.first();

    if (!photo) {
      return res.status(404).json({
        success: false,
        error: 'Photo not found'
      });
    }

    // Generate signed URLs
    const photoUrl = await s3.getSignedUrlPromise('getObject', {
      Bucket: process.env.S3_BUCKET_NAME,
      Key: photo.s3_key,
      Expires: 3600
    });

    let thumbnailUrl = null;
    if (photo.thumbnail_s3_key) {
      thumbnailUrl = await s3.getSignedUrlPromise('getObject', {
        Bucket: process.env.S3_BUCKET_NAME,
        Key: photo.thumbnail_s3_key,
        Expires: 3600
      });
    }

    // Log photo view
    await auditLogger.log({
      userId: req.user.id,
      action: 'VIEW',
      resourceType: 'photo',
      resourceId: id,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: {
        ...photo,
        photo_url: photoUrl,
        thumbnail_url: thumbnailUrl,
        metadata: photo.metadata ? JSON.parse(photo.metadata) : {}
      }
    });
  } catch (error) {
    logger.error('Get photo error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve photo'
    });
  }
});

// @route   PUT /api/v1/photos/:id/approve
// @desc    Approve photo (Manager only)
// @access  Private (Manager/Admin)
router.put('/:id/approve', authenticateToken, requireManager, async (req, res) => {
  try {
    const { id } = req.params;

    const photo = await db('photos')
      .where({ id, status: 'pending' })
      .first();

    if (!photo) {
      return res.status(404).json({
        success: false,
        error: 'Pending photo not found'
      });
    }

    const oldValues = { status: photo.status };
    const newValues = {
      status: 'approved',
      approved_by: req.user.id,
      approved_at: new Date(),
      updated_at: new Date()
    };

    await db('photos')
      .where({ id })
      .update(newValues);

    // Log approval
    await auditLogger.log({
      userId: req.user.id,
      action: 'APPROVE',
      resourceType: 'photo',
      resourceId: id,
      oldValues,
      newValues,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Photo approved successfully'
    });
  } catch (error) {
    logger.error('Approve photo error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to approve photo'
    });
  }
});

// @route   PUT /api/v1/photos/:id/reject
// @desc    Reject photo (Manager only)
// @access  Private (Manager/Admin)
router.put('/:id/reject', authenticateToken, requireManager, [
  body('reason').notEmpty().withMessage('Rejection reason is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { id } = req.params;
    const { reason } = req.body;

    const photo = await db('photos')
      .where({ id, status: 'pending' })
      .first();

    if (!photo) {
      return res.status(404).json({
        success: false,
        error: 'Pending photo not found'
      });
    }

    const oldValues = { status: photo.status };
    const newValues = {
      status: 'rejected',
      rejection_reason: reason,
      approved_by: req.user.id,
      approved_at: new Date(),
      updated_at: new Date()
    };

    await db('photos')
      .where({ id })
      .update(newValues);

    // Log rejection
    await auditLogger.log({
      userId: req.user.id,
      action: 'REJECT',
      resourceType: 'photo',
      resourceId: id,
      oldValues,
      newValues,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Photo rejected successfully'
    });
  } catch (error) {
    logger.error('Reject photo error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to reject photo'
    });
  }
});

// @route   DELETE /api/v1/photos/:id
// @desc    Delete photo (Manager only)
// @access  Private (Manager/Admin)
router.delete('/:id', authenticateToken, requireManager, async (req, res) => {
  try {
    const { id } = req.params;

    const photo = await db('photos')
      .where({ id })
      .where('status', '!=', 'deleted')
      .first();

    if (!photo) {
      return res.status(404).json({
        success: false,
        error: 'Photo not found'
      });
    }

    // Soft delete - mark as deleted instead of actually deleting
    const oldValues = { status: photo.status };
    const newValues = {
      status: 'deleted',
      updated_at: new Date()
    };

    await db('photos')
      .where({ id })
      .update(newValues);

    // Log deletion
    await auditLogger.log({
      userId: req.user.id,
      action: 'DELETE',
      resourceType: 'photo',
      resourceId: id,
      oldValues,
      newValues,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Photo deleted successfully'
    });
  } catch (error) {
    logger.error('Delete photo error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete photo'
    });
  }
});

module.exports = router;