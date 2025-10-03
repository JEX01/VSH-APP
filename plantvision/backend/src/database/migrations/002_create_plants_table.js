/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('plants', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('plant_code', 20).notNullable().unique();
    table.string('plant_name', 255).notNullable();
    table.text('description');
    table.string('location', 255);
    table.decimal('latitude', 10, 8);
    table.decimal('longitude', 11, 8);
    table.string('contact_person', 100);
    table.string('contact_phone', 20);
    table.string('contact_email', 255);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    
    // Indexes
    table.index(['plant_code']);
    table.index(['is_active']);
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('plants');
};