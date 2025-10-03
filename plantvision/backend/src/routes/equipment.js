const express = require('express');
const { query, validationResult } = require('express-validator');
const db = require('../database/connection');
const { authenticateToken } = require('../middleware/auth');
const auditLogger = require('../utils/auditLogger');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/equipment
// @desc    Get equipment list with filtering and pagination
// @access  Private
router.get('/', authenticateToken, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('plantId').optional().isUUID().withMessage('Plant ID must be a valid UUID'),
  query('equipmentType').optional().isLength({ min: 1 }).withMessage('Equipment type cannot be empty'),
  query('status').optional().isIn(['active', 'maintenance', 'inactive']).withMessage('Invalid status'),
  query('search').optional().isLength({ min: 1 }).withMessage('Search term cannot be empty')
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
      limit = 50,
      plantId,
      equipmentType,
      status,
      search
    } = req.query;

    const offset = (page - 1) * limit;

    let query = db('equipment')
      .select(
        'equipment.*',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('plants', 'equipment.plant_id', 'plants.id')
      .orderBy('equipment.equipment_code');

    // Role-based filtering
    if (req.user.role === 'worker' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    // Apply filters
    if (plantId) {
      query = query.where('equipment.plant_id', plantId);
    }

    if (equipmentType) {
      query = query.where('equipment.equipment_type', equipmentType);
    }

    if (status) {
      query = query.where('equipment.status', status);
    }

    if (search) {
      query = query.where(function() {
        this.where('equipment.equipment_code', 'ilike', `%${search}%`)
            .orWhere('equipment.equipment_name', 'ilike', `%${search}%`)
            .orWhere('equipment.description', 'ilike', `%${search}%`);
      });
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('equipment.id as count');

    // Get paginated results
    const equipment = await query.limit(limit).offset(offset);

    res.json({
      success: true,
      data: {
        equipment: equipment.map(item => ({
          ...item,
          specifications: item.specifications ? JSON.parse(item.specifications) : {}
        })),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(total),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get equipment error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment'
    });
  }
});

// @route   GET /api/v1/equipment/:id
// @desc    Get single equipment by ID
// @access  Private
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    let query = db('equipment')
      .select(
        'equipment.*',
        'plants.plant_code',
        'plants.plant_name',
        'plants.location as plant_location'
      )
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('equipment.id', id);

    // Role-based access control
    if (req.user.role === 'worker' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    const equipment = await query.first();

    if (!equipment) {
      return res.status(404).json({
        success: false,
        error: 'Equipment not found'
      });
    }

    // Get recent photos count
    const [{ count: photoCount }] = await db('photos')
      .where({ equipment_id: id })
      .where('status', '!=', 'deleted')
      .count('* as count');

    // Get recent tasks count
    const [{ count: taskCount }] = await db('tasks')
      .where({ equipment_id: id })
      .count('* as count');

    // Log equipment view
    await auditLogger.log({
      userId: req.user.id,
      action: 'VIEW',
      resourceType: 'equipment',
      resourceId: id,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: {
        ...equipment,
        specifications: equipment.specifications ? JSON.parse(equipment.specifications) : {},
        photoCount: parseInt(photoCount),
        taskCount: parseInt(taskCount)
      }
    });
  } catch (error) {
    logger.error('Get equipment error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment'
    });
  }
});

// @route   GET /api/v1/equipment/qr/:qrCode
// @desc    Get equipment by QR code
// @access  Private
router.get('/qr/:qrCode', authenticateToken, async (req, res) => {
  try {
    const { qrCode } = req.params;

    let query = db('equipment')
      .select(
        'equipment.*',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('equipment.qr_code', qrCode);

    // Role-based access control
    if (req.user.role === 'worker' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    const equipment = await query.first();

    if (!equipment) {
      return res.status(404).json({
        success: false,
        error: 'Equipment not found for this QR code'
      });
    }

    // Log QR scan
    await auditLogger.log({
      userId: req.user.id,
      action: 'QR_SCAN',
      resourceType: 'equipment',
      resourceId: equipment.id,
      metadata: { qrCode },
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: {
        ...equipment,
        specifications: equipment.specifications ? JSON.parse(equipment.specifications) : {}
      }
    });
  } catch (error) {
    logger.error('Get equipment by QR error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment'
    });
  }
});

// @route   GET /api/v1/equipment/types
// @desc    Get unique equipment types
// @access  Private
router.get('/types', authenticateToken, async (req, res) => {
  try {
    let query = db('equipment')
      .distinct('equipment_type')
      .whereNotNull('equipment_type')
      .orderBy('equipment_type');

    // Role-based filtering
    if (req.user.role === 'worker' && req.user.plantArea) {
      query = query.where('location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('location_area', req.user.plantArea);
    }

    const types = await query;

    res.json({
      success: true,
      data: types.map(t => t.equipment_type).filter(Boolean)
    });
  } catch (error) {
    logger.error('Get equipment types error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment types'
    });
  }
});

// @route   GET /api/v1/equipment/:id/photos
// @desc    Get photos for specific equipment
// @access  Private
router.get('/:id/photos', authenticateToken, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'approved', 'rejected']).withMessage('Invalid status'),
  query('startDate').optional().isISO8601().withMessage('Start date must be a valid ISO date'),
  query('endDate').optional().isISO8601().withMessage('End date must be a valid ISO date')
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
    const {
      page = 1,
      limit = 20,
      status,
      startDate,
      endDate
    } = req.query;

    const offset = (page - 1) * limit;

    // Verify equipment exists and user has access
    let equipmentQuery = db('equipment')
      .where('id', id);

    if (req.user.role === 'worker' && req.user.plantArea) {
      equipmentQuery = equipmentQuery.where('location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      equipmentQuery = equipmentQuery.where('location_area', req.user.plantArea);
    }

    const equipment = await equipmentQuery.first();

    if (!equipment) {
      return res.status(404).json({
        success: false,
        error: 'Equipment not found'
      });
    }

    let query = db('photos')
      .select(
        'photos.*',
        'users.username',
        'users.first_name',
        'users.last_name'
      )
      .join('users', 'photos.user_id', 'users.id')
      .where('photos.equipment_id', id)
      .where('photos.status', '!=', 'deleted')
      .orderBy('photos.captured_at', 'desc');

    // Role-based filtering
    if (req.user.role === 'worker') {
      query = query.where('photos.user_id', req.user.id);
    }

    // Apply filters
    if (status) {
      query = query.where('photos.status', status);
    }

    if (startDate) {
      query = query.where('photos.captured_at', '>=', new Date(startDate));
    }

    if (endDate) {
      query = query.where('photos.captured_at', '<=', new Date(endDate));
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('photos.id as count');

    // Get paginated results
    const photos = await query.limit(limit).offset(offset);

    res.json({
      success: true,
      data: {
        equipment: {
          id: equipment.id,
          equipmentCode: equipment.equipment_code,
          equipmentName: equipment.equipment_name,
          equipmentType: equipment.equipment_type
        },
        photos,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(total),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get equipment photos error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment photos'
    });
  }
});

// @route   GET /api/v1/equipment/:id/tasks
// @desc    Get tasks for specific equipment
// @access  Private
router.get('/:id/tasks', authenticateToken, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'in_progress', 'completed', 'cancelled']).withMessage('Invalid status')
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
    const {
      page = 1,
      limit = 20,
      status
    } = req.query;

    const offset = (page - 1) * limit;

    // Verify equipment exists and user has access
    let equipmentQuery = db('equipment')
      .where('id', id);

    if (req.user.role === 'worker' && req.user.plantArea) {
      equipmentQuery = equipmentQuery.where('location_area', req.user.plantArea);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      equipmentQuery = equipmentQuery.where('location_area', req.user.plantArea);
    }

    const equipment = await equipmentQuery.first();

    if (!equipment) {
      return res.status(404).json({
        success: false,
        error: 'Equipment not found'
      });
    }

    let query = db('tasks')
      .select(
        'tasks.*',
        'assigned_user.username as assigned_username',
        'assigned_user.first_name as assigned_first_name',
        'assigned_user.last_name as assigned_last_name',
        'assigner.username as assigner_username',
        'assigner.first_name as assigner_first_name',
        'assigner.last_name as assigner_last_name'
      )
      .join('users as assigned_user', 'tasks.assigned_to', 'assigned_user.id')
      .join('users as assigner', 'tasks.assigned_by', 'assigner.id')
      .where('tasks.equipment_id', id)
      .orderBy('tasks.created_at', 'desc');

    // Role-based filtering
    if (req.user.role === 'worker') {
      query = query.where('tasks.assigned_to', req.user.id);
    }

    // Apply filters
    if (status) {
      query = query.where('tasks.status', status);
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('tasks.id as count');

    // Get paginated results
    const tasks = await query.limit(limit).offset(offset);

    res.json({
      success: true,
      data: {
        equipment: {
          id: equipment.id,
          equipmentCode: equipment.equipment_code,
          equipmentName: equipment.equipment_name,
          equipmentType: equipment.equipment_type
        },
        tasks,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(total),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get equipment tasks error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve equipment tasks'
    });
  }
});

module.exports = router;