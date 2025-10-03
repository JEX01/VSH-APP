const db = require('../database/connection');
const logger = require('./logger');

class AuditLogger {
  static async log({
    userId,
    action,
    resourceType,
    resourceId = null,
    oldValues = {},
    newValues = {},
    metadata = {},
    ipAddress = null,
    userAgent = null
  }) {
    try {
      await db('audit_logs').insert({
        user_id: userId,
        action: action.toUpperCase(),
        resource_type: resourceType.toLowerCase(),
        resource_id: resourceId,
        old_values: JSON.stringify(oldValues),
        new_values: JSON.stringify(newValues),
        metadata: JSON.stringify(metadata),
        ip_address: ipAddress,
        user_agent: userAgent,
        created_at: new Date()
      });

      logger.info('Audit log created', {
        userId,
        action,
        resourceType,
        resourceId,
        ipAddress
      });
    } catch (error) {
      logger.error('Failed to create audit log:', error);
      // Don't throw error to avoid breaking the main operation
    }
  }

  static async getAuditLogs({
    userId = null,
    resourceType = null,
    resourceId = null,
    action = null,
    startDate = null,
    endDate = null,
    limit = 50,
    offset = 0
  }) {
    try {
      let query = db('audit_logs')
        .select(
          'audit_logs.*',
          'users.username',
          'users.first_name',
          'users.last_name'
        )
        .leftJoin('users', 'audit_logs.user_id', 'users.id')
        .orderBy('audit_logs.created_at', 'desc');

      if (userId) {
        query = query.where('audit_logs.user_id', userId);
      }

      if (resourceType) {
        query = query.where('audit_logs.resource_type', resourceType);
      }

      if (resourceId) {
        query = query.where('audit_logs.resource_id', resourceId);
      }

      if (action) {
        query = query.where('audit_logs.action', action.toUpperCase());
      }

      if (startDate) {
        query = query.where('audit_logs.created_at', '>=', startDate);
      }

      if (endDate) {
        query = query.where('audit_logs.created_at', '<=', endDate);
      }

      const logs = await query.limit(limit).offset(offset);

      // Parse JSON fields
      return logs.map(log => ({
        ...log,
        old_values: log.old_values ? JSON.parse(log.old_values) : {},
        new_values: log.new_values ? JSON.parse(log.new_values) : {},
        metadata: log.metadata ? JSON.parse(log.metadata) : {}
      }));
    } catch (error) {
      logger.error('Failed to get audit logs:', error);
      throw error;
    }
  }

  static async getAuditLogStats({
    userId = null,
    startDate = null,
    endDate = null
  }) {
    try {
      let query = db('audit_logs');

      if (userId) {
        query = query.where('user_id', userId);
      }

      if (startDate) {
        query = query.where('created_at', '>=', startDate);
      }

      if (endDate) {
        query = query.where('created_at', '<=', endDate);
      }

      const stats = await query
        .select('action')
        .count('* as count')
        .groupBy('action');

      return stats.reduce((acc, stat) => {
        acc[stat.action.toLowerCase()] = parseInt(stat.count);
        return acc;
      }, {});
    } catch (error) {
      logger.error('Failed to get audit log stats:', error);
      throw error;
    }
  }

  // Cleanup old audit logs (should be run as a scheduled job)
  static async cleanup(retentionDays = 365) {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

      const deletedCount = await db('audit_logs')
        .where('created_at', '<', cutoffDate)
        .del();

      logger.info(`Cleaned up ${deletedCount} old audit logs`);
      return deletedCount;
    } catch (error) {
      logger.error('Failed to cleanup audit logs:', error);
      throw error;
    }
  }
}

module.exports = AuditLogger;