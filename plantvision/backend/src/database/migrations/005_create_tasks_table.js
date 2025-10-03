/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('tasks', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('assigned_to').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('assigned_by').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('equipment_id').notNullable().references('id').inTable('equipment').onDelete('CASCADE');
    table.string('title', 255).notNullable();
    table.text('description');
    table.enum('priority', ['low', 'medium', 'high', 'urgent']).notNullable().defaultTo('medium');
    table.enum('status', ['pending', 'in_progress', 'completed', 'cancelled']).notNullable().defaultTo('pending');
    table.timestamp('due_date');
    table.timestamp('started_at');
    table.timestamp('completed_at');
    table.text('completion_notes');
    table.uuid('completion_photo_id').references('id').inTable('photos');
    table.json('metadata').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['assigned_to']);
    table.index(['assigned_by']);
    table.index(['equipment_id']);
    table.index(['status']);
    table.index(['priority']);
    table.index(['due_date']);
    table.index(['created_at']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('tasks');
};