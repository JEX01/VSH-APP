const express = require('express');
const { query, validationResult } = require('express-validator');
const { authenticateToken, requireManager } = require('../middleware/auth');
const auditLogger = require('../utils/auditLogger');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/audit/logs
// @desc    Get audit logs (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/logs', authenticateToken, requireManager, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('userId').optional().isUUID().withMessage('User ID must be a valid UUID'),
  query('action').optional().isLength({ min: 1 }).withMessage('Action cannot be empty'),
  query('resourceType').optional().isLength({ min: 1 }).withMessage('Resource type cannot be empty'),
  query('resourceId').optional().isUUID().withMessage('Resource ID must be a valid UUID'),
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

    const {
      page = 1,
      limit = 50,
      userId,
      action,
      resourceType,
      resourceId,
      startDate,
      endDate
    } = req.query;

    const offset = (page - 1) * limit;

    const logs = await auditLogger.getAuditLogs({
      userId,
      action,
      resourceType,
      resourceId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      limit: parseInt(limit),
      offset
    });

    // Get total count for pagination
    const totalLogs = await auditLogger.getAuditLogs({
      userId,
      action,
      resourceType,
      resourceId,
      startDate: startDate ? new Date(startDate) : null,
      endDate: endDate ? new Date(endDate) : null,
      limit: 999999 // Large number to get all records for counting
    });

    res.json({
      success: true,
      data: {
        logs,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: totalLogs.length,
          pages: Math.ceil(totalLogs.length / limit)
        }
      }
    });
  } catch (error) {
    logger.error('Get audit logs error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve audit logs'
    });
  }
});

// @route   GET /api/v1/audit/stats
// @desc    Get audit statistics (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/stats', authenticateToken, requireManager, [
  query('days').optional().isInt({ min: 1, max: 365 }).withMessage('Days must be between 1 and 365'),
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

    const { days = 30, userId } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const stats = await auditLogger.getAuditLogStats({
      userId,
      startDate,
      endDate: new Date()
    });

    res.json({
      success: true,
      data: {
        period: {
          days: parseInt(days),
          startDate: startDate.toISOString(),
          endDate: new Date().toISOString()
        },
        actionCounts: stats,
        totalActions: Object.values(stats).reduce((sum, count) => sum + count, 0)
      }
    });
  } catch (error) {
    logger.error('Get audit stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve audit statistics'
    });
  }
});

// @route   GET /api/v1/audit/user/:userId
// @desc    Get audit logs for specific user (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/user/:userId', authenticateToken, requireManager, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('action').optional().isLength({ min: 1 }).withMessage('Action cannot be empty'),
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

    const { userId } = req.params;
    const {
      page = 1,
      limit = 50,
      action,
      days = 30
    } = req.query;

    const offset = (page - 1) * limit;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const logs = await auditLogger.getAuditLogs({
      userId,
      action,
      startDate,
      endDate: new Date(),
      limit: parseInt(limit),
      offset
    });

    // Get stats for this user
    const stats = await auditLogger.getAuditLogStats({
      userId,
      startDate,
      endDate: new Date()
    });

    res.json({
      success: true,
      data: {
        userId,
        period: {
          days: parseInt(days),
          startDate: startDate.toISOString(),
          endDate: new Date().toISOString()
        },
        logs,
        stats,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: logs.length // This is approximate since we're using limit/offset
        }
      }
    });
  } catch (error) {
    logger.error('Get user audit logs error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve user audit logs'
    });
  }
});

// @route   GET /api/v1/audit/resource/:resourceType/:resourceId
// @desc    Get audit logs for specific resource (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/resource/:resourceType/:resourceId', authenticateToken, requireManager, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
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

    const { resourceType, resourceId } = req.params;
    const {
      page = 1,
      limit = 50
    } = req.query;

    const offset = (page - 1) * limit;

    const logs = await auditLogger.getAuditLogs({
      resourceType,
      resourceId,
      limit: parseInt(limit),
      offset
    });

    res.json({
      success: true,
      data: {
        resourceType,
        resourceId,
        logs,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: logs.length // This is approximate since we're using limit/offset
        }
      }
    });
  } catch (error) {
    logger.error('Get resource audit logs error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve resource audit logs'
    });
  }
});

// @route   POST /api/v1/audit/cleanup
// @desc    Cleanup old audit logs (Admin only)
// @access  Private (Admin)
router.post('/cleanup', authenticateToken, requireManager, [
  query('retentionDays').optional().isInt({ min: 30, max: 3650 }).withMessage('Retention days must be between 30 and 3650')
], async (req, res) => {
  try {
    // Only allow admin users to cleanup audit logs
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Only administrators can cleanup audit logs'
      });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { retentionDays = 365 } = req.query;

    const deletedCount = await auditLogger.cleanup(parseInt(retentionDays));

    // Log the cleanup action
    await auditLogger.log({
      userId: req.user.id,
      action: 'CLEANUP',
      resourceType: 'audit_logs',
      metadata: {
        retentionDays: parseInt(retentionDays),
        deletedCount
      },
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: {
        message: 'Audit logs cleanup completed',
        deletedCount,
        retentionDays: parseInt(retentionDays)
      }
    });
  } catch (error) {
    logger.error('Audit logs cleanup error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to cleanup audit logs'
    });
  }
});

// @route   GET /api/v1/audit/actions
// @desc    Get list of available audit actions (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/actions', authenticateToken, requireManager, async (req, res) => {
  try {
    const actions = [
      'CREATE',
      'UPDATE',
      'DELETE',
      'VIEW',
      'LOGIN_SUCCESS',
      'LOGIN_FAILED',
      'LOGOUT',
      'PASSWORD_CHANGE',
      'APPROVE',
      'REJECT',
      'ACTIVATE',
      'DEACTIVATE',
      'QR_SCAN',
      'UNAUTHORIZED_ACCESS',
      'CLEANUP'
    ];

    res.json({
      success: true,
      data: actions
    });
  } catch (error) {
    logger.error('Get audit actions error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve audit actions'
    });
  }
});

// @route   GET /api/v1/audit/resource-types
// @desc    Get list of available resource types (Manager/Admin only)
// @access  Private (Manager/Admin)
router.get('/resource-types', authenticateToken, requireManager, async (req, res) => {
  try {
    const resourceTypes = [
      'user',
      'photo',
      'task',
      'equipment',
      'plant',
      'auth',
      'audit_logs',
      'endpoint'
    ];

    res.json({
      success: true,
      data: resourceTypes
    });
  } catch (error) {
    logger.error('Get resource types error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve resource types'
    });
  }
});

module.exports = router;