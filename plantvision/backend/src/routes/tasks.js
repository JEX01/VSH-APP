const express = require('express');
const { body, query, validationResult } = require('express-validator');
const db = require('../database/connection');
const { authenticateToken, requireManager } = require('../middleware/auth');
const auditLogger = require('../utils/auditLogger');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/tasks
// @desc    Create new task (Manager only)
// @access  Private (Manager/Admin)
router.post('/', authenticateToken, requireManager, [
  body('assignedTo').isUUID().withMessage('Valid user ID is required'),
  body('equipmentId').isUUID().withMessage('Valid equipment ID is required'),
  body('title').isLength({ min: 1, max: 255 }).withMessage('Title is required and must be less than 255 characters'),
  body('description').optional().isLength({ max: 1000 }).withMessage('Description cannot exceed 1000 characters'),
  body('priority').optional().isIn(['low', 'medium', 'high', 'urgent']).withMessage('Invalid priority level'),
  body('dueDate').optional().isISO8601().withMessage('Due date must be a valid ISO date')
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
      assignedTo,
      equipmentId,
      title,
      description,
      priority = 'medium',
      dueDate
    } = req.body;

    // Verify assigned user exists and is a worker
    const assignedUser = await db('users')
      .where({ id: assignedTo, is_active: true })
      .first();

    if (!assignedUser) {
      return res.status(404).json({
        success: false,
        error: 'Assigned user not found or inactive'
      });
    }

    // Verify equipment exists
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

    // Check manager's plant area access (if applicable)
    if (req.user.role === 'manager' && req.user.plantArea && req.user.plantArea !== equipment.location_area) {
      return res.status(403).json({
        success: false,
        error: 'Access denied to this equipment area'
      });
    }

    const taskData = {
      assigned_to: assignedTo,
      assigned_by: req.user.id,
      equipment_id: equipmentId,
      title,
      description,
      priority,
      due_date: dueDate ? new Date(dueDate) : null,
      status: 'pending'
    };

    const [taskId] = await db('tasks').insert(taskData).returning('id');

    // Log task creation
    await auditLogger.log({
      userId: req.user.id,
      action: 'CREATE',
      resourceType: 'task',
      resourceId: taskId,
      newValues: taskData,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    // TODO: Send push notification to assigned user
    // await notificationService.sendTaskAssignment(assignedTo, taskId, title);

    res.status(201).json({
      success: true,
      data: {
        id: taskId,
        message: 'Task created successfully'
      }
    });
  } catch (error) {
    logger.error('Create task error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create task'
    });
  }
});

// @route   GET /api/v1/tasks
// @desc    Get tasks with filtering and pagination
// @access  Private
router.get('/', authenticateToken, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'in_progress', 'completed', 'cancelled']).withMessage('Invalid status'),
  query('priority').optional().isIn(['low', 'medium', 'high', 'urgent']).withMessage('Invalid priority'),
  query('assignedTo').optional().isUUID().withMessage('Assigned to must be a valid UUID'),
  query('equipmentId').optional().isUUID().withMessage('Equipment ID must be a valid UUID'),
  query('overdue').optional().isBoolean().withMessage('Overdue must be a boolean')
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
      status,
      priority,
      assignedTo,
      equipmentId,
      overdue
    } = req.query;

    const offset = (page - 1) * limit;

    let query = db('tasks')
      .select(
        'tasks.*',
        'assigned_user.username as assigned_username',
        'assigned_user.first_name as assigned_first_name',
        'assigned_user.last_name as assigned_last_name',
        'assigner.username as assigner_username',
        'assigner.first_name as assigner_first_name',
        'assigner.last_name as assigner_last_name',
        'equipment.equipment_code',
        'equipment.equipment_name',
        'equipment.equipment_type',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('users as assigned_user', 'tasks.assigned_to', 'assigned_user.id')
      .join('users as assigner', 'tasks.assigned_by', 'assigner.id')
      .join('equipment', 'tasks.equipment_id', 'equipment.id')
      .join('plants', 'equipment.plant_id', 'plants.id')
      .orderBy('tasks.created_at', 'desc');

    // Role-based filtering
    if (req.user.role === 'worker') {
      // Workers can only see tasks assigned to them
      query = query.where('tasks.assigned_to', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      // Managers can see tasks in their plant area
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    // Apply filters
    if (status) {
      query = query.where('tasks.status', status);
    }

    if (priority) {
      query = query.where('tasks.priority', priority);
    }

    if (assignedTo && req.user.role !== 'worker') {
      query = query.where('tasks.assigned_to', assignedTo);
    }

    if (equipmentId) {
      query = query.where('tasks.equipment_id', equipmentId);
    }

    if (overdue === 'true') {
      query = query.where('tasks.due_date', '<', new Date())
                   .whereIn('tasks.status', ['pending', 'in_progress']);
    }

    // Get total count for pagination
    const totalQuery = query.clone();
    const [{ count: total }] = await totalQuery.count('tasks.id as count');

    // Get paginated results
    const tasks = await query.limit(limit).offset(offset);

    res.json({
      success: true,
      data: {
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
    logger.error('Get tasks error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve tasks'
    });
  }
});

// @route   GET /api/v1/tasks/:id
// @desc    Get single task by ID
// @access  Private
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    let query = db('tasks')
      .select(
        'tasks.*',
        'assigned_user.username as assigned_username',
        'assigned_user.first_name as assigned_first_name',
        'assigned_user.last_name as assigned_last_name',
        'assigner.username as assigner_username',
        'assigner.first_name as assigner_first_name',
        'assigner.last_name as assigner_last_name',
        'equipment.equipment_code',
        'equipment.equipment_name',
        'equipment.equipment_type',
        'equipment.location_area',
        'plants.plant_code',
        'plants.plant_name'
      )
      .join('users as assigned_user', 'tasks.assigned_to', 'assigned_user.id')
      .join('users as assigner', 'tasks.assigned_by', 'assigner.id')
      .join('equipment', 'tasks.equipment_id', 'equipment.id')
      .join('plants', 'equipment.plant_id', 'plants.id')
      .where('tasks.id', id);

    // Role-based access control
    if (req.user.role === 'worker') {
      query = query.where('tasks.assigned_to', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      query = query.where('equipment.location_area', req.user.plantArea);
    }

    const task = await query.first();

    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }

    // Log task view
    await auditLogger.log({
      userId: req.user.id,
      action: 'VIEW',
      resourceType: 'task',
      resourceId: id,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      data: task
    });
  } catch (error) {
    logger.error('Get task error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve task'
    });
  }
});

// @route   PUT /api/v1/tasks/:id/status
// @desc    Update task status
// @access  Private
router.put('/:id/status', authenticateToken, [
  body('status').isIn(['pending', 'in_progress', 'completed', 'cancelled']).withMessage('Invalid status'),
  body('completionNotes').optional().isLength({ max: 1000 }).withMessage('Completion notes cannot exceed 1000 characters'),
  body('completionPhotoId').optional().isUUID().withMessage('Completion photo ID must be a valid UUID')
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
    const { status, completionNotes, completionPhotoId } = req.body;

    // Get current task
    let taskQuery = db('tasks')
      .select('tasks.*', 'equipment.location_area')
      .join('equipment', 'tasks.equipment_id', 'equipment.id')
      .where('tasks.id', id);

    // Role-based access control
    if (req.user.role === 'worker') {
      taskQuery = taskQuery.where('tasks.assigned_to', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      taskQuery = taskQuery.where('equipment.location_area', req.user.plantArea);
    }

    const task = await taskQuery.first();

    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found or access denied'
      });
    }

    // Validate status transitions
    const validTransitions = {
      'pending': ['in_progress', 'cancelled'],
      'in_progress': ['completed', 'cancelled'],
      'completed': [], // Completed tasks cannot be changed
      'cancelled': ['pending'] // Only managers can reopen cancelled tasks
    };

    if (!validTransitions[task.status].includes(status)) {
      // Special case: only managers can reopen cancelled tasks
      if (task.status === 'cancelled' && status === 'pending' && req.user.role !== 'manager') {
        return res.status(403).json({
          success: false,
          error: 'Only managers can reopen cancelled tasks'
        });
      }

      if (task.status === 'completed') {
        return res.status(400).json({
          success: false,
          error: 'Completed tasks cannot be modified'
        });
      }

      return res.status(400).json({
        success: false,
        error: `Cannot change status from ${task.status} to ${status}`
      });
    }

    // Verify completion photo if provided
    if (completionPhotoId) {
      const photo = await db('photos')
        .where({ id: completionPhotoId, user_id: req.user.id })
        .first();

      if (!photo) {
        return res.status(404).json({
          success: false,
          error: 'Completion photo not found'
        });
      }
    }

    const oldValues = {
      status: task.status,
      started_at: task.started_at,
      completed_at: task.completed_at,
      completion_notes: task.completion_notes,
      completion_photo_id: task.completion_photo_id
    };

    const updateData = {
      status,
      updated_at: new Date()
    };

    // Set timestamps based on status
    if (status === 'in_progress' && !task.started_at) {
      updateData.started_at = new Date();
    }

    if (status === 'completed') {
      updateData.completed_at = new Date();
      if (completionNotes) {
        updateData.completion_notes = completionNotes;
      }
      if (completionPhotoId) {
        updateData.completion_photo_id = completionPhotoId;
      }
    }

    await db('tasks')
      .where({ id })
      .update(updateData);

    // Log status update
    await auditLogger.log({
      userId: req.user.id,
      action: 'UPDATE',
      resourceType: 'task',
      resourceId: id,
      oldValues,
      newValues: updateData,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Task status updated successfully'
    });
  } catch (error) {
    logger.error('Update task status error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update task status'
    });
  }
});

// @route   PUT /api/v1/tasks/:id
// @desc    Update task details (Manager only)
// @access  Private (Manager/Admin)
router.put('/:id', authenticateToken, requireManager, [
  body('title').optional().isLength({ min: 1, max: 255 }).withMessage('Title must be less than 255 characters'),
  body('description').optional().isLength({ max: 1000 }).withMessage('Description cannot exceed 1000 characters'),
  body('priority').optional().isIn(['low', 'medium', 'high', 'urgent']).withMessage('Invalid priority level'),
  body('dueDate').optional().isISO8601().withMessage('Due date must be a valid ISO date'),
  body('assignedTo').optional().isUUID().withMessage('Assigned to must be a valid UUID')
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
    const { title, description, priority, dueDate, assignedTo } = req.body;

    // Get current task
    const task = await db('tasks')
      .select('tasks.*', 'equipment.location_area')
      .join('equipment', 'tasks.equipment_id', 'equipment.id')
      .where('tasks.id', id)
      .first();

    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }

    // Check manager's plant area access
    if (req.user.role === 'manager' && req.user.plantArea && req.user.plantArea !== task.location_area) {
      return res.status(403).json({
        success: false,
        error: 'Access denied to this task'
      });
    }

    // Verify new assigned user if provided
    if (assignedTo && assignedTo !== task.assigned_to) {
      const assignedUser = await db('users')
        .where({ id: assignedTo, is_active: true })
        .first();

      if (!assignedUser) {
        return res.status(404).json({
          success: false,
          error: 'Assigned user not found or inactive'
        });
      }
    }

    const oldValues = {
      title: task.title,
      description: task.description,
      priority: task.priority,
      due_date: task.due_date,
      assigned_to: task.assigned_to
    };

    const updateData = {
      updated_at: new Date()
    };

    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (priority !== undefined) updateData.priority = priority;
    if (dueDate !== undefined) updateData.due_date = dueDate ? new Date(dueDate) : null;
    if (assignedTo !== undefined) updateData.assigned_to = assignedTo;

    await db('tasks')
      .where({ id })
      .update(updateData);

    // Log task update
    await auditLogger.log({
      userId: req.user.id,
      action: 'UPDATE',
      resourceType: 'task',
      resourceId: id,
      oldValues,
      newValues: updateData,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Task updated successfully'
    });
  } catch (error) {
    logger.error('Update task error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update task'
    });
  }
});

// @route   DELETE /api/v1/tasks/:id
// @desc    Delete task (Manager only)
// @access  Private (Manager/Admin)
router.delete('/:id', authenticateToken, requireManager, async (req, res) => {
  try {
    const { id } = req.params;

    // Get task to verify access and log deletion
    const task = await db('tasks')
      .select('tasks.*', 'equipment.location_area')
      .join('equipment', 'tasks.equipment_id', 'equipment.id')
      .where('tasks.id', id)
      .first();

    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }

    // Check manager's plant area access
    if (req.user.role === 'manager' && req.user.plantArea && req.user.plantArea !== task.location_area) {
      return res.status(403).json({
        success: false,
        error: 'Access denied to this task'
      });
    }

    // Don't allow deletion of completed tasks
    if (task.status === 'completed') {
      return res.status(400).json({
        success: false,
        error: 'Cannot delete completed tasks'
      });
    }

    await db('tasks')
      .where({ id })
      .del();

    // Log task deletion
    await auditLogger.log({
      userId: req.user.id,
      action: 'DELETE',
      resourceType: 'task',
      resourceId: id,
      oldValues: task,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent')
    });

    res.json({
      success: true,
      message: 'Task deleted successfully'
    });
  } catch (error) {
    logger.error('Delete task error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete task'
    });
  }
});

// @route   GET /api/v1/tasks/stats
// @desc    Get task statistics
// @access  Private
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    let baseQuery = db('tasks')
      .join('equipment', 'tasks.equipment_id', 'equipment.id');

    // Role-based filtering
    if (req.user.role === 'worker') {
      baseQuery = baseQuery.where('tasks.assigned_to', req.user.id);
    } else if (req.user.role === 'manager' && req.user.plantArea) {
      baseQuery = baseQuery.where('equipment.location_area', req.user.plantArea);
    }

    // Get status counts
    const statusStats = await baseQuery.clone()
      .select('tasks.status')
      .count('* as count')
      .groupBy('tasks.status');

    // Get priority counts
    const priorityStats = await baseQuery.clone()
      .select('tasks.priority')
      .count('* as count')
      .groupBy('tasks.priority');

    // Get overdue count
    const [{ count: overdueCount }] = await baseQuery.clone()
      .where('tasks.due_date', '<', new Date())
      .whereIn('tasks.status', ['pending', 'in_progress'])
      .count('* as count');

    // Get completion rate for the last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [{ count: totalLast30Days }] = await baseQuery.clone()
      .where('tasks.created_at', '>=', thirtyDaysAgo)
      .count('* as count');

    const [{ count: completedLast30Days }] = await baseQuery.clone()
      .where('tasks.created_at', '>=', thirtyDaysAgo)
      .where('tasks.status', 'completed')
      .count('* as count');

    const completionRate = totalLast30Days > 0 ? (completedLast30Days / totalLast30Days * 100).toFixed(1) : 0;

    res.json({
      success: true,
      data: {
        statusCounts: statusStats.reduce((acc, stat) => {
          acc[stat.status] = parseInt(stat.count);
          return acc;
        }, {}),
        priorityCounts: priorityStats.reduce((acc, stat) => {
          acc[stat.priority] = parseInt(stat.count);
          return acc;
        }, {}),
        overdueCount: parseInt(overdueCount),
        completionRate: parseFloat(completionRate),
        period: {
          totalTasks: parseInt(totalLast30Days),
          completedTasks: parseInt(completedLast30Days),
          days: 30
        }
      }
    });
  } catch (error) {
    logger.error('Get task stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve task statistics'
    });
  }
});

module.exports = router;