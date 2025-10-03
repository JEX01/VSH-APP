/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('users', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('username', 50).notNullable().unique();
    table.string('email', 255).notNullable().unique();
    table.string('password_hash', 255).notNullable();
    table.string('first_name', 100).notNullable();
    table.string('last_name', 100).notNullable();
    table.enum('role', ['worker', 'manager', 'admin']).notNullable().defaultTo('worker');
    table.string('employee_id', 50).unique();
    table.string('department', 100);
    table.string('plant_area', 100);
    table.string('phone', 20);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.boolean('email_verified').notNullable().defaultTo(false);
    table.timestamp('last_login_at');
    table.string('fcm_token', 500); // For push notifications
    table.json('preferences').defaultTo('{}');
    table.timestamps(true, true);
    
    // Indexes
    table.index(['role']);
    table.index(['plant_area']);
    table.index(['is_active']);
    table.index(['employee_id']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('users');
};