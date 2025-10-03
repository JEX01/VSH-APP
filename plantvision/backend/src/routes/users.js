const express = require('express');
const { query, validationResult } = require('express-validator');
const db = require('../database/connection');
const { authenticateToken, requireManager } = require('../middleware/auth');
const auditLogger = require('../utils/auditLogger');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/users
// @desc    Get users list (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/', authenticateToken, requireManager, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('role').optional().isIn(['worker', 'manager', 'admin']).withMessage('Invalid role'),
  query('plantArea').optional().isLength({ min: 1 }).withMessage('Plant area cannot be empty'),
  query('isActive').optional().isBoolean().withMessage('Is active must be a boolean'),
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
      limit = 20,
      role,
      plantArea,
      isActive,
      search
    } = req.query;

    const offset = (page - 1) * limit;

    let query = db('users')
      .select(
        'id', 'username', 'email', 'first_name', 'last_name',
        'role', 'employee_id', 'department', 'plant_area', 'phone',
        'is_active', 'created_at', 'last_login_at'
      )
      .orderBy('created_at', 'desc');

    // Role-based filtering - managers can only see users in their plant area
    if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('plant_area', req.user.plantArea);
    }

    // Apply filters
    if (role) {
      query = query.where('role', role);
    }

    if (plantArea && req.user.role === 'admin') {
      query = query.where('plant_area', plantArea);
    }

    if (isActive !== undefined) {
      query = query.where('is_active', isActive === 'true');
    }

    if (search) {
      query = query.where(function() {
        this.where('username', 'ilike', `%${search}%`)
            .orWhere('first_name', 'ilike', `%${search}%`)
            .orWhere('last_name', 'ilike', `%${search}%`)
            .orWhere('email', 'ilike', `%${search}%`)
            .orWhere('employee_id', 'ilike', `%${search}%`);
      });
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('id as count');

    // Get paginated results
    const users = await query.limit(limit).offset(offset);

    res.json({
      success: true,
      data: {
        users,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(total),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get users error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve users'
    });
  }
});

// @route   GET /api/v1/users/:id
// @desc    Get single user by ID (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/:id', authenticateToken, requireManager, async (req, res) => {
  try {
    const { id } = req.params;

    let query = db('users')
      .select(
        'id', 'username', 'email', 'first_name', 'last_name',
        'role', 'employee_id', 'department', 'plant_area', 'phone',
        'is_active', 'email_verified', 'created_at', 'last_login_at', 'preferences'
      )
      .where('id', id);

    // Role-based access control
    if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('plant_area', req.user.plantArea);
    }

    const user = await query.first();

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Get user statistics
    const [{ count: photoCount }] = await db('photos')
      .where({ user_id: id })
      .where('status', '!=', 'deleted')
      .count('* as count');

    const [{ count: taskCount }] = await db('tasks')
      .where({ assigned_to: id })
      .count('* as count');

    const [{ count: completedTaskCount }] = await db('tasks')
      .where({ assigned_to: id, status: 'completed' })
      .count('* as count');

    // Log user view
    await auditLogger.log({
      userId: req.user.id,
      action: 'VIEW',
      resourceType: 'user',
      resourceId: id,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: {
        ...user,
        preferences: user.preferences ? JSON.parse(user.preferences) : {},
        statistics: {
          photoCount: parseInt(photoCount),
          taskCount: parseInt(taskCount),
          completedTaskCount: parseInt(completedTaskCount),
          completionRate: taskCount > 0 ? ((completedTaskCount / taskCount) * 100).toFixed(1) : 0
        }
      }
    });
  } catch (error) {
    logger.error('Get user error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve user'
    });
  }
});

// @route   GET /api/v1/users/workers/list
// @desc    Get list of workers for task assignment (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/workers/list', authenticateToken, requireManager, async (req, res) => {
  try {
    let query = db('users')
      .select('id', 'username', 'first_name', 'last_name', 'employee_id', 'plant_area')
      .where({ role: 'worker', is_active: true })
      .orderBy('first_name');

    // Role-based filtering - managers can only see workers in their plant area
    if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('plant_area', req.user.plantArea);
    }

    const workers = await query;

    res.json({
      success: true,
      data: workers
    });
  } catch (error) {
    logger.error('Get workers list error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve workers list'
    });
  }
});

// @route   GET /api/v1/users/:id/activity
// @desc    Get user activity summary (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/:id/activity', authenticateToken, requireManager, [
  query('days').optional().isInt({ min: 1, max: 365 }).withMessage('Days must be between 1 and 365')
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
    const { days = 30 } = req.query;

    // Verify user exists and access
    let userQuery = db('users')
      .select('id', 'username', 'first_name', 'last_name', 'plant_area')
      .where('id', id);

    if (req.user.role === 'manager' && req.user.plantArea) {
      userQuery = userQuery.where('plant_area', req.user.plantArea);
    }

    const user = await userQuery.first();

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get photo activity
    const photoActivity = await db('photos')
      .select(
        db.raw('DATE(created_at) as date'),
        db.raw('COUNT(*) as count')
      )
      .where('user_id', id)
      .where('created_at', '>=', startDate)
      .groupBy(db.raw('DATE(created_at)'))
      .orderBy('date');

    // Get task activity
    const taskActivity = await db('tasks')
      .select(
        db.raw('DATE(updated_at) as date'),
        'status',
        db.raw('COUNT(*) as count')
      )
      .where('assigned_to', id)
      .where('updated_at', '>=', startDate)
      .groupBy(db.raw('DATE(updated_at)'), 'status')
      .orderBy('date');

    // Get recent audit logs
    const recentActivity = await auditLogger.getAuditLogs({
      userId: id,
      startDate,
      limit: 20
    });

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          firstName: user.first_name,
          lastName: user.last_name
        },
        period: {
          days: parseInt(days),
          startDate: startDate.toISOString(),
          endDate: new Date().toISOString()
        },
        photoActivity,
        taskActivity,
        recentActivity
      }
    });
  } catch (error) {
    logger.error('Get user activity error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve user activity'
    });
  }
});

// @route   PUT /api/v1/users/:id/status
// @desc    Update user active status (Admin only)
// @access  Private (Admin)
router.put('/:id/status', authenticateToken, requireManager, async (req, res) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        success: false,
        error: 'isActive must be a boolean value'
      });
    }

    // Prevent self-deactivation
    if (id === req.user.id && !isActive) {
      return res.status(400).json({
        success: false,
        error: 'Cannot deactivate your own account'
      });
    }

    // Get current user
    let userQuery = db('users')
      .where('id', id);

    if (req.user.role === 'manager' && req.user.plantArea) {
      userQuery = userQuery.where('plant_area', req.user.plantArea);
    }

    const user = await userQuery.first();

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const oldValues = { is_active: user.is_active };
    const newValues = {
      is_active: isActive,
      updated_at: new Date()
    };

    await db('users')
      .where('id', id)
      .update(newValues);

    // Log status change
    await auditLogger.log({
      userId: req.user.id,
      action: isActive ? 'ACTIVATE' : 'DEACTIVATE',
      resourceType: 'user',
      resourceId: id,
      oldValues,
      newValues,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: `User ${isActive ? 'activated' : 'deactivated'} successfully`
    });
  } catch (error) {
    logger.error('Update user status error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update user status'
    });
  }
});

// @route   GET /api/v1/users/stats/overview
// @desc    Get users overview statistics (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/stats/overview', authenticateToken, requireManager, async (req, res) => {
  try {
    let baseQuery = db('users');

    // Role-based filtering
    if (req.user.role === 'manager' && req.user.plantArea) {
      baseQuery = baseQuery.where('plant_area', req.user.plantArea);
    }

    // Get role counts
    const roleStats = await baseQuery.clone()
      .select('role')
      .count('* as count')
      .groupBy('role');

    // Get active/inactive counts
    const statusStats = await baseQuery.clone()
      .select('is_active')
      .count('* as count')
      .groupBy('is_active');

    // Get recent login activity (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const [{ count: recentLoginCount }] = await baseQuery.clone()
      .where('last_login_at', '>=', sevenDaysAgo)
      .count('* as count');

    // Get total users
    const [{ count: totalUsers }] = await baseQuery.clone()
      .count('* as count');

    res.json({
      success: true,
      data: {
        totalUsers: parseInt(totalUsers),
        roleCounts: roleStats.reduce((acc, stat) => {
          acc[stat.role] = parseInt(stat.count);
          return acc;
        }, {}),
        statusCounts: statusStats.reduce((acc, stat) => {
          acc[stat.is_active ? 'active' : 'inactive'] = parseInt(stat.count);
          return acc;
        }, {}),
        recentLoginCount: parseInt(recentLoginCount),
        loginRate: totalUsers > 0 ? ((recentLoginCount / totalUsers) * 100).toFixed(1) : 0
      }
    });
  } catch (error) {
    logger.error('Get users stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve users statistics'
    });
  }
});

module.exports = router;