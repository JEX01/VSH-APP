/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('audit_logs', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('action', 100).notNullable(); // CREATE, UPDATE, DELETE, VIEW, APPROVE, REJECT
    table.string('resource_type', 50).notNullable(); // photo, task, user, equipment
    table.uuid('resource_id');
    table.json('old_values').defaultTo('{}');
    table.json('new_values').defaultTo('{}');
    table.string('ip_address', 45);
    table.string('user_agent', 500);
    table.json('metadata').defaultTo('{}');
    table.timestamp('created_at').defaultTo(knex.fn.now());
    
    // Indexes
    table.index(['user_id']);
    table.index(['action']);
    table.index(['resource_type']);
    table.index(['resource_id']);
    table.index(['created_at']);
    table.index(['user_id', 'created_at']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('audit_logs');
};